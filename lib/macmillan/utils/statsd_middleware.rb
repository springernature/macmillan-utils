require 'set'

module Macmillan
  module Utils
    ##
    # Rack Middleware for sending request timings and other statistics to StatsD.
    #
    # This code is heavily inspired by https://github.com/manderson26/statsd/blob/master/lib/statsd/middleware.rb
    #
    # == Usage:
    #
    # In config.ru:
    #
    #   require 'statsd'
    #   require 'macmillan/utils/statsd_decorator'
    #   require 'macmillan/utils/statsd_middleware'
    #
    #   statsd = Statsd.new('http://statsd.example.com', 8080)
    #   statsd = Macmillan::Utils::StatsdDecorator.new(statsd, ENV['RACK_ENV'])
    #
    #   use Macmillan::Utils::StatsdMiddleware, client: statsd
    #
    # By default this middleware will record timer and increment stats for all requests under
    # the statsd/graphite namespace 'rack.' - i.e.
    #
    # * rack.timers.request - timers per request
    # * rack.increments.request - increments per request
    # * rack.http_status.request.<status code> - increment per request
    # * rack.exception - increment upon error
    #
    # Facilities are provided via {Macmillan::Utils::StatsdControllerHelper} to also log
    # per-route metrics via this middleware.
    #
    class StatsdMiddleware
      NAMESPACE  = 'rack'.freeze
      TIMERS     = 'statsd.timers'.freeze
      INCREMENTS = 'statsd.increments'.freeze

      def initialize(app, opts = {})
        raise ArgumentError, 'You must supply a StatsD client' unless opts[:client]

        @app    = app
        @client = opts[:client]
      end

      def call(env)
        dup.process(env)
      end

      def process(env)
        setup(env)

        (status, headers, body), response_time = call_with_timing(env)

        record_metrics(env, status, response_time)

        [status, headers, body]
      rescue => error
        @client.increment("#{NAMESPACE}.exception")
        raise error
      end

      private

      def setup(env)
        env[TIMERS]     = Set.new(['request'])
        env[INCREMENTS] = Set.new(['request'])
      end

      def record_metrics(env, status, response_time)
        env[TIMERS].each do |key|
          @client.timing("#{NAMESPACE}.timers.#{key}", response_time)
        end

        env[INCREMENTS].each do |key|
          @client.increment("#{NAMESPACE}.increments.#{key}")
          @client.increment("#{NAMESPACE}.http_status.#{key}.#{status}")
        end
      end

      def call_with_timing(env)
        start  = Time.now
        result = @app.call(env)
        [result, ((Time.now - start) * 1000).round]
      end
    end
  end
end
