module Macmillan
  module Utils
    ##
    # A test helper class for stubbing out interaction with StatsD.
    #
    # === Usage (in spec/spec_helper.rb):
    #
    #   require 'macmillan/utils/statsd_stub'
    #
    #   RSpec.configure do |config|
    #     config.before(:suite) do
    #       $statsd = Macmillan::Utils::StatsdStub.new
    #     end
    #   end
    #
    # @see Macmillan::Utils::StatsdDecorator
    # @see http://rubygems.org/gems/statsd-ruby
    #
    class StatsdStub
      def increment(_stat, _sample_rate = 1)
      end

      def decrement(_stat, _sample_rate = 1)
      end

      def count(_stat, _count, _sample_rate = 1)
      end

      def guage(_stat, _value, _sample_rate = 1)
      end

      def set(_stat, _value, _sample_rate = 1)
      end

      def timing(_stat, _ms, _sample_rate = 1)
      end

      def time(_stat, _sample_rate = 1)
        yield
      end
    end
  end
end
