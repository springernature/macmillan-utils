require 'yaml'

module Macmillan
  module Utils
    module Settings
      class AppYamlBackend
        def get(key)
          backend_key = key.to_s.downcase
          return KeyNotFound.new(key, self, backend_key) unless yaml.key?(backend_key)
          Value.new(key, yaml[backend_key], self, backend_key)
        end

        private

        def yaml
          @yaml ||= begin
            YAML.load(File.open(application_yml_path))
          end
        end

        def application_yml_path
          search_pattern  = File.join('config', 'application.yml')
          here            = File.expand_path(Dir.pwd)
          path_components = here.split(/\//)
          found_path      = nil

          path_components.size.downto(1) do |path_size|
            break if found_path
            search_path = path_components[0, path_size]
            search_file = File.join(search_path, search_pattern)
            found_path  = search_file if File.exist?(search_file)
          end

          raise 'cannot find application.yml' if found_path.nil?

          found_path
        end
      end
    end
  end
end
