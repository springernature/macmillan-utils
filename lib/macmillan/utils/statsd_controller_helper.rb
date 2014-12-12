require_relative 'statsd_middleware'

module Macmillan
  module Utils
    ##
    # Helper functions for working with {Macmillan::Utils::StatsdMiddleware}
    # in Rack based web applications.
    #
    # This code is heavily inspired by {https://github.com/mleinart/sinatra-statsd-helper sinatra-statsd-helper}
    #
    # == Usage:
    #
    # Add 'macmillan-utils' to your Gemfile:
    #
    #   gem 'macmillan-utils', require: false
    #
    # First, setup the {Macmillan::Utils::StatsdMiddleware} as described in its
    # documentation. Then simply include this module in your controller classes.
    #
    # i.e. in Sinatra
    #
    #   require 'macmillan/utils/statsd_controller_helper'
    #
    #   class Server < Sinatra::Base
    #     include Macmillan::Utils::StatsdControllerHelper
    #
    #     get '/' do
    #       add_statsd_timer('get.homepage') # sends a timer to the stat 'get.homepage' with the timing of the request
    #     end
    #
    #     get '/inc' do
    #       add_statsd_increment('get.inc') # sends an increment to the stat 'get.inc'
    #     end
    #
    #     get '/both' do
    #       add_statsd_timer_and_increment('get.both') # sends both an timer and increment stat to 'get.both'
    #     end
    #   end
    #
    # Rails works identically:
    #
    #   require 'macmillan/utils/statsd_controller_helper'
    #
    #   class SiteController < ApplicationController
    #     include Macmillan::Utils::StatsdControllerHelper
    #
    #     def index
    #       add_statsd_timer_and_increment('get.site_controller.index')
    #     end
    #   end
    #
    module StatsdControllerHelper
      module_function

      ##
      # Send a timer stat to statsd (with the timing of the whole rack request)
      #
      # @param key [String] the statsd/graphite statistic name/key
      def add_statsd_timer(key)
        request.env[::Macmillan::Utils::StatsdMiddleware::TIMERS] << key
      end

      ##
      # Send an increment stat to statsd
      #
      # @param key [String] the statsd/graphite statistic name/key
      def add_statsd_increment(key)
        request.env[::Macmillan::Utils::StatsdMiddleware::INCREMENTS] << key
      end

      ##
      # Send both a timer and an increment stat to statsd
      #
      # @param key [String] the statsd/graphite statistic name/key
      def add_statsd_timer_and_increment(key)
        add_statsd_timer(key)
        add_statsd_increment(key)
      end
    end
  end
end
