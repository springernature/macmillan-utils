module Macmillan
  module Utils
    module Settings
      class Lookup
        def initialize(backends)
          @backends = backends
        end

        def lookup(key)
          @backends.each do |backend|
            result = backend.get(key)
            return result.value unless result.is_a?(KeyNotFound)
          end

          raise KeyNotFoundError.new("Cannot find a settings value for #{key}")
        end

        # Backwards compatibility: in the past this has been used like a Hash
        alias [] lookup
        alias fetch lookup
      end
    end
  end
end
