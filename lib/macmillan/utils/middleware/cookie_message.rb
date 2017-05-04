require 'rack/request'
require 'rack/response'
require 'uri'
require 'active_support/tagged_logging'

module Macmillan
  module Utils
    module Middleware
      class CookieMessage
        YEAR = 31_536_000
        COOKIE = 'euCookieNotice'.freeze

        def initialize(app, options = {})
          @app = app
          @log_level = options[:log_level]

          if (logger = options[:logger])
            build_tagged_logger(logger)
          end
        end

        def call(env)
          @request = Rack::Request.new(env)

          build_tagged_logger(logger)

          if cookies_accepted?(@request)
            redirect_back(@request)
          else
            @app.call(env)
          end
        end

        private

        def build_tagged_logger(logger)
          if logger.respond_to?(:tagged)
            @logger = logger
          else
            @logger = ActiveSupport::TaggedLogging.new(logger)
          end
        end

        def cookies_accepted?(request)
          debug("request.post? IS #{request.post?.inspect}")
          debug("request.cookies[#{COOKIE}] IS #{request.cookies[COOKIE].inspect}")
          debug("request.params['cookies'] IS #{request.params['cookies'].inspect}")
          debug("request.cookies IS #{request.cookies.inspect}")

          unless request.post?
            debug("request.post? (#{request.post?.inspect}) means passthru")
            return false
          end

          unless request.cookies[COOKIE] != 'accepted'
            debug("request.cookies['#{COOKIE}'] (#{request.cookies[COOKIE].inspect}) means passthru")
            return false
          end

          unless request.params['cookies'] == 'accepted'
            debug("request.params['cookies'] (#{request.params['cookies'].inspect}) means passthru")
            return false
          end

          debug('About to set the acceptance cookie and redirect')
          true
        end

        def debug(msg)
          logger.tagged(self.class.name) { logger.debug(msg) }
        end

        def logger
          @logger ||= @request.logger || default_logger
        end

        def default_logger
          logger = ::Logger.new($stdout)
          logger.level = default_log_level

          ActiveSupport::TaggedLogging.new(logger)
        end

        def default_log_level
          @log_level || ::Logger::INFO
        end

        def redirect_back(request)
          response = Rack::Response.new
          location = build_location(request)

          debug("Redirecting to #{location}")

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
            debug("Attempting to determine redirect by parsing referrer #{request.referrer}")
            uri = URI.parse(request.referrer.to_s)
          rescue URI::InvalidURIError
            debug("No that failed, attempting to determine redirect by parsing request.url #{request.url}")
            uri = URI.parse(request.url)
          end

          # Check that the redirect is an internal one for security reasons:
          # https://webmasters.googleblog.com/2009/01/open-redirect-urls-is-your-site-being.html
          if internal_redirect?(request, uri)
            uri.to_s
          else
            debug("Not internal redirect - so changing to #{request.url} instead of the above")
            request.url
          end
        end

        def internal_redirect?(request, uri)
          debug("Is redirect to #{uri.host}:#{uri.port} internal WRT #{request.host}:#{request.port}")
          request.host == uri.host # && request.port == uri.port
        end
      end
    end
  end
end
