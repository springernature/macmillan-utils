require 'rack/request'
require 'rack/response'
require 'uri'

module Macmillan
  module Utils
    module Middleware
      class CookieMessage
        YEAR = 31_536_000
        COOKIE = 'euCookieNotice'.freeze

        def initialize(app)
          @app = app
        end

        def call(env)
          @request = Rack::Request.new(env)

          if cookies_accepted?(@request)
            redirect_back(@request)
          else
            @app.call(env)
          end
        end

        private

        def cookies_accepted?(request)

          debug_log('request.post? IS #{request.post?.inspect}')
          debug_log('request.cookies[#{COOKIE}] IS #{request.cookies[COOKIE]}')
          debug_log("request.params['cookies'] IS #{request.params['cookies']}")

          unless request.post?
            debug_log('request.post? means pass-thru')
            return false
          end
          unless request.cookies[COOKIE] != 'accepted'
            debug_log('request.cookies[#{COOKIE}] means passthru')
            return false
          end
          unless request.params['cookies'] == 'accepted'
            debug_log("request.params['cookies'] means passthru")
            return false
          end
          debug_log('About to set the acceptance cookie and redirect')
          true
        end

        def debug_log(msg)
          logger.info("[Macmillan::Utils::Middleware::CookieMessage] #{msg}")
        end

        def logger
          @logger ||= @request.logger || NullLogger.new
        end

        def redirect_back(request)
          response = Rack::Response.new
          location = build_location(request)

          response.redirect(location)
          response.set_cookie(COOKIE, cookie_options(request))

          response.to_a
        end

        def cookie_options(request)
          {
            value:   'accepted',
            domain:  request.host_with_port,
            path:    '/',
            expires: Time.now.getutc + YEAR
          }
        end

        def build_location(request)
          begin
            uri = URI.parse(request.referrer.to_s)
          rescue URI::InvalidURIError
            uri = URI.parse(request.url)
          end

          # Check that the redirect is an internal one for security reasons:
          # https://webmasters.googleblog.com/2009/01/open-redirect-urls-is-your-site-being.html
          internal_redirect?(request, uri) ? uri.to_s : request.url
        end

        def internal_redirect?(request, uri)
          request.host == uri.host && request.port == uri.port
        end

        class NullLogger
          def method_missing(*args)
            nil
          end
        end
      end
    end
  end
end
