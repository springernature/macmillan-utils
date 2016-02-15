module Macmillan
  module Utils
    module Helper
      module StringConversionHelper
        module_function

        # shamelessly ripped out of the 'facets' gem
        def snakecase_string(string)
          string
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr('-', '_')
            .gsub(/\s/, '_')
            .gsub(/__+/, '_')
            .downcase
        end

        # also shamelessly ripped out of the 'facets' gem
        def upper_camelcase_string(string)
          separators = ['_', '\s']

          separators.each do |s|
            string = string.gsub(/(?:#{s}+)([a-z])/) { Regexp.last_match(1).upcase }
          end

          string.gsub(/(\A|\s)([a-z])/) { Regexp.last_match(1) + Regexp.last_match(2).upcase }
        end

        def camelcase_to_snakecase_symbol(string)
          snakecase_string(string).to_sym
        end
      end
    end
  end
end
