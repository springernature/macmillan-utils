##
# Namespace for Macmillan code...
#
module Macmillan
  ##
  # Utils module for use in Macmillan applications
  #
  module Utils
    autoload :VERSION,         'macmillan/utils/version'
    autoload :Logger,          'macmillan/utils/logger'
    autoload :StatsdDecorator, 'macmillan/utils/statsd_decorator'
  end
end
