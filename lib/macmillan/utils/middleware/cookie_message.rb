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
          request = Rack::Request.new(env)

          if cookies_accepted?(request)
            redirect_back(request)
          else
            @app.call(env)
          end
        end

        private

        def cookies_accepted?(request)
          request.post? &&
            request.cookies[COOKIE] != 'accepted' &&
            request.params['cookies'] == 'accepted'
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
      end
    end
  end
end
