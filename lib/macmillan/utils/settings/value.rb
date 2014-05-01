module Macmillan
  module Utils
    module Settings
      class Value
        attr_reader :value

        def initialize lookup_key, value, backend, backend_key
          @lookup_key  = lookup_key
          @value       = value
          @backend     = backend
          @backend_key = backend_key
        end
      end
    end
  end
end
