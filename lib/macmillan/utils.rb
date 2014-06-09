##
# Namespace for Macmillan code...
#
module Macmillan
  ##
  # Utils module for use in Macmillan applications
  #
  module Utils
    autoload :Logger,          'macmillan/utils/logger'
    autoload :Settings,        'macmillan/utils/settings'
    autoload :StatsdDecorator, 'macmillan/utils/statsd_decorator'
    autoload :VERSION,         'macmillan/utils/version'
  end
end
