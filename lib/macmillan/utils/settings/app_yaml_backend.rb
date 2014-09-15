require 'yaml'

module Macmillan
  module Utils
    module Settings
      class AppYamlBackend
        def get(key)
          return build_value(key) if yaml.key?(key)
          KeyNotFound.new(key, self, key)
        end

        private

        def build_value(key)
          Value.new(key, yaml[key], self, key)
        end

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
            search_path = path_components[0,path_size]
            search_file = File.join(search_path, search_pattern)
            found_path  = search_file if File.exist?(search_file)
          end

          fail 'cannot find application.yml' if found_path.nil?

          found_path
        end
      end
    end
  end
end
