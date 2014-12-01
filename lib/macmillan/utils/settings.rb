module Macmillan
  module Utils
    module Settings
      autoload :AppYamlBackend, 'macmillan/utils/settings/app_yaml_backend'
      autoload :EnvVarsBackend, 'macmillan/utils/settings/env_vars_backend'
      autoload :Lookup,         'macmillan/utils/settings/lookup'
      autoload :Value,          'macmillan/utils/settings/value'
      autoload :KeyNotFound,    'macmillan/utils/settings/key_not_found'

      class KeyNotFoundError < StandardError; end

      class << self
        # Get an instance of the settings looker-upper
        def instance
          @instance ||= begin
            backend_instances = backends.map(&:new)
            Lookup.new(backend_instances)
          end
        end

        # Backends must respond to the following interface:
        #   # `.new`    :: Return an instance of the backend
        #   # `#get key`:: Return a Value for the key.
        #               :: If there's no setting, return
        #               :: a KeyNotFound
        #
        attr_accessor :backends
      end

      self.backends = [EnvVarsBackend, AppYamlBackend]
    end
  end
end
