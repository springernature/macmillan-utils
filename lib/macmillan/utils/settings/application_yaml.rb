require 'yaml'

module Macmillan
  module Utils
    module Settings
      class ApplicationYaml
        def get(key)
          return build_value(key) if yaml.key? key
          KeyNotFound.new key, self
        end

        private

        def build_value(key)
          Value.new key, yaml[key], self, key
        end

        def yaml
          @yaml ||= begin
            erb_yaml = File.read application_yml_path
            template = ERB.new erb_yaml
            yaml     = template.result binding
            YAML.load yaml
          rescue
            {}
          end
        end

        def application_yml_path
          search_pattern = File.join 'config', 'application.yml.erb'
          here = File.expand_path Dir.pwd
          path_components = here.split /\//
          path_components.size.downto(1) do |path_size|
            search_path = path_components[0,path_size]
            search_file = File.join search_path, search_pattern
            return search_file if File.exists? search_file
          end
        end
      end
    end
  end
end
