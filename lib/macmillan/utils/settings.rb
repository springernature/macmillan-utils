module Macmillan
  module Utils
    module Settings
      autoload :ApplicationYaml,    'macmillan/utils/settings/application_yaml'
      autoload :ProcessEnvironment, 'macmillan/utils/settings/process_environment'

      autoload :Lookup,             'macmillan/utils/settings/lookup'

      autoload :Value,              'macmillan/utils/settings/value'
      autoload :KeyNotFound,        'macmillan/utils/settings/key_not_found'

      class << self
        # Get an instance of the settings looker-upper
        def instance
          @instance ||= begin
            backend_instances = backends.map do |backend|
              backend.new
            end
            Lookup.new backend_instances
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

      self.backends = [
        ProcessEnvironment,
        ApplicationYaml
      ]
    end
  end
end
