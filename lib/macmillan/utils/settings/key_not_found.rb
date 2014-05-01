module Macmillan
  module Utils
    module Settings
      class KeyNotFound
        def initialize lookup_key, backend, backend_key
          @lookup_key  = lookup_key
          @backend     = backend
          @backend_key = backend_key
        end
      end
    end
  end
end
