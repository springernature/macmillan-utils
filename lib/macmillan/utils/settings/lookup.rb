module Macmillan
  module Utils
    module Settings
      class Lookup
        def initialize(backends)
          @backends = backends
        end

        def lookup(key, default = nil)
          @backends.each do |backend|
            result = backend.get key
            return result.value unless result.kind_of? KeyNotFound
          end
          default
        end
        # Backwards compatibility: in the past this has been used like a Hash
        alias_method :[], :lookup
        alias_method :fetch, :lookup
      end
    end
  end
end
