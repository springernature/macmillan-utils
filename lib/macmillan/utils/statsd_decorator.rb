module Macmillan
  module Utils
    ##
    # Utility class to wrap the Statsd class from {http://rubygems.org/gems/statsd-ruby statsd-ruby}.
    #
    # This will allow you to log Statsd messages to your logs, but only
    # really send messages to the StatsD server when running in a
    # 'production' environment.
    #
    # === Usage:
    #
    # Add 'statsd-ruby' and 'macmillan-utils' to your Gemfile:
    #
    #   gem 'statsd-ruby'
    #   gem 'macmillan-utils', require: false
    #
    # Then in your code:
    #
    #   require 'statsd'
    #   require 'macmillan/utils/statsd_decorator'
    #
    #   statsd = Statsd.new('http://statsd.example.com', 8080)
    #   statsd = Macmillan::Utils::StatsdDecorator.new(statsd, ENV['RACK_ENV'])
    #
    # i.e. when using rails, use the rails env and logger:
    #
    #   statsd = Statsd.new('http://statsd.example.com', 8080)
    #   statsd = Macmillan::Utils::StatsdDecorator.new(statsd, Rails.env, Rails.logger)
    #
    # @see http://rubygems.org/gems/statsd-ruby
    #
    class StatsdDecorator < SimpleDelegator
      attr_accessor :env, :logger

      ##
      # Builds a new instance of StatsdDecorator
      #
      # @param delegatee [Statsd] a Statsd object
      # @param env [String] the current application environment - i.e. 'development' or 'production'
      # @param logger [Logger] a Logger object
      # @return [Statsd] the decorated Statsd class
      #
      def initialize(delegatee, env = 'development', logger = Macmillan::Utils::Logger::Factory.build_logger)
        @env    = env
        @logger = logger
        super(delegatee)
      end

      def increment(stat, sample_rate = 1)
        log_stat %Q{increment - "#{stat}" (sample_rate: #{sample_rate})}
        super if send_to_delegatee?
      end

      def decrement(stat, sample_rate = 1)
        log_stat %Q{decrement - "#{stat}" (sample_rate: #{sample_rate})}
        super if send_to_delegatee?
      end

      def count(stat, count, sample_rate = 1)
        log_stat %Q{count - "#{stat}" #{count} (sample_rate: #{sample_rate})}
        super if send_to_delegatee?
      end

      def guage(stat, value, sample_rate = 1)
        log_stat %Q{gauge - "#{stat}" #{value} (sample_rate: #{sample_rate})}
        super if send_to_delegatee?
      end

      def set(stat, value, sample_rate = 1)
        log_stat %Q{set - "#{stat}" #{value} (sample_rate: #{sample_rate})}
        super if send_to_delegatee?
      end

      def timing(stat, ms, sample_rate = 1)
        log_stat %Q{timing - "#{stat}" #{ms}ms (sample_rate: #{sample_rate})}
        super if send_to_delegatee?
      end

      def time(stat, sample_rate = 1, &block)
        start    = Time.now
        result   = block.call
        duration = ((Time.now - start) * 1000).round
        timing(stat, duration, sample_rate)
        result
      end

      private

      def log_stat(msg)
        logger.info "[StatsD] #{msg}"
      end

      def send_to_delegatee?
        env == 'production'
      end
    end
  end
end
