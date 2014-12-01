module Macmillan
  module Utils
    module Settings
      class Lookup
        def initialize(backends)
          @backends = backends
        end

        def lookup(key)
          value = nil

          @backends.each do |backend|
            break if value
            result = backend.get(key)
            value  = result.value unless result.is_a?(KeyNotFound)
          end

          fail KeyNotFoundError.new("Cannot find a settings value for #{key}") unless value

          value
        end

        # Backwards compatibility: in the past this has been used like a Hash
        alias_method :[], :lookup
        alias_method :fetch, :lookup
      end
    end
  end
end
