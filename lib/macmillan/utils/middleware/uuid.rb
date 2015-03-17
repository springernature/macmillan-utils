module Macmillan
  module Utils
    module Middleware
      ##
      # Rack Middleware for uniquley identifying a user.
      #
      # If the user is logged in, their UUID will be based upon their user_id, otherwise
      # it will be randomly generated.  This UUID will be stored in the rack env, and
      # persisted in a cookie.
      #
      # This middleware expects a user object to be stored in the rack env.
      #
      class Uuid
        def self.env_key
          'user.uuid'
        end

        def initialize(app, opts={})
          @app            = app
          @user_env_key   = opts[:user_env_key] || 'current_user'
          @user_id_method = opts[:user_id_method] || 'user_id'
        end

        class CallHandler
          attr_reader :app, :request, :user_env_key, :user_id_method, :cookie_key

          def initialize(env, app, user_env_key, user_id_method, cookie_key)
            @app            = app
            @request        = Rack::Request.new(env)
            @user_env_key   = user_env_key
            @user_id_method = user_id_method
            @cookie_key     = cookie_key

            env[cookie_key] = user_uuid
          end

          def response
            @response ||= begin
                            status, headers, body = app.call(request.env)
                            Rack::Response.new(body, status, headers)
                          end
          end

          def finish
            save_cookie if store_cookie?
            clean_old_cookies
            response.finish
          end

          def user
            request.env[user_env_key]
          end

          def user_uuid
            @user_uuid ||= begin
                             if user
                               Digest::SHA1.hexdigest(user.public_send(user_id_method).to_s)
                             elsif cookie_uuid
                               cookie_uuid
                             else
                               SecureRandom.uuid
                             end
                           end
          end

          def cookie_uuid
            request.cookies[cookie_key]
          end

          def store_cookie?
            user_uuid != cookie_uuid
          end

          def save_cookie
            response.set_cookie(cookie_key, { value: user_uuid, path: '/', expires: DateTime.now.next_year.to_time })
          end

          def clean_old_cookies
            response.delete_cookie('bandiera.uuid') if request.cookies['bandiera.uuid']
            response.delete_cookie('sherlock.uuid') if request.cookies['sherlock.uuid']
            response.delete_cookie('sixpack.uuid') if request.cookies['sixpack.uuid']
          end
        end

        def call(env)
          dup.process(env)
        end

        def process(env)
          handler = CallHandler.new(env, @app, @user_env_key, @user_id_method, self.class.env_key)
          handler.finish
        end
      end
    end
  end
end
