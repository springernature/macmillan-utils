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
      def increment(stat, sample_rate=1)
      end

      def decrement(stat, sample_rate=1)
      end

      def count(stat, count, sample_rate=1)
      end

      def guage(stat, value, sample_rate=1)
      end

      def set(stat, value, sample_rate=1)
      end

      def timing(stat, ms, sample_rate=1)
      end

      def time(stat, sample_rate=1)
        yield
      end
    end
  end
end
