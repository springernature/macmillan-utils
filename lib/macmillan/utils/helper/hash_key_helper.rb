module Macmillan
  module Utils
    module Helper
      module HashKeyHelper
        include StringConversionHelper

        def convert_keys_to_snakecase_and_symbols(obj)
          case obj
          when Array
            obj.reduce([]) do |res, val|
              res << case val
                     when Hash, Array
                       convert_keys_to_snakecase_and_symbols(val)
                     else
                       val
                     end
              res
            end
          when Hash
            obj.reduce({}) do |res, (key, val)|
              nkey = snakecase_string(key.to_s).to_sym
              nval = case val
                     when Hash, Array
                       convert_keys_to_snakecase_and_symbols(val)
                     else
                       val
                     end
              res[nkey] = nval
              res
            end
          else
            obj
          end
        end

        def convert_key_to_singular(key)
          if key.to_s == 'summaries'
            :summary
          else
            key.to_s.chomp('s').to_sym
          end
        end
      end
    end
  end
end
