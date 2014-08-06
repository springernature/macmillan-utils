module Macmillan
  module Utils
    module Settings
      class EnvVarsBackend
        def get(key)
          backend_key = key.to_s.upcase
          return KeyNotFound.new(key, self, backend_key) unless ENV.key?(backend_key)
          Value.new(key, ENV[backend_key].dup, self, backend_key)
        end
      end
    end
  end
end
