module Macmillan
  module Utils
    module Logger
      ##
      # A log formatter class for Logger objects.  This formatter is used automatically
      # when you use the {Macmillan::Utils::Logger::Factory} class.
      #
      # === Usage:
      #
      #   require 'macmillan/utils/logger'
      #
      #   logger = Macmillan::Utils::Logger::Factory.build_logger(type, options)
      #
      class Formatter < ::Logger::Formatter
        ##
        # Builds a new instance of Formatter
        #
        # @param prefix [String] a string to prepend to all log lines
        # @return [Formatter] the configured formatter object
        #
        def initialize(prefix = nil)
          @format = '[%5s]: %s'
          @format = "#{prefix} #{@format}" if prefix
        end

        ##
        # Returns the log message formatted as desired
        #
        def call(severity, _time, _progname, msg)
          @format % [severity, msg2str(msg)]
        end

        protected

        def msg2str(msg)
          case msg
          when ::String
            msg
          when ::Exception
            "#{msg.message} (#{msg.class})\n" << (msg.backtrace || []).join("\n")
          else
            msg.inspect
          end
        end
      end
    end
  end
end
