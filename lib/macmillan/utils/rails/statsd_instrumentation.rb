require 'socket'

##
# Default $statsD instrumentation for Rails applications
#
# ASSUMPTION: Your StatsD client is stored in a global variable $statsd
#
# Usage (in `config/initializers/statsd.rb`):
#
#   require 'statsd-ruby'
#   require 'macmillan/utils/statsd_decorator'
#
#   $statsd = Statsd.new('http://statsd.example.com', 8080)
#   $statsd = Macmillan::Utils::StatsdDecorator.new($statsd, Rails.env, Rails.logger)
#
#   require 'macmillan/utils/rails/statsd_instrumentation'
#
# Options (Set as environment variables):
#
#   STRIP_DOMAIN_FROM_HOST = domain name (string) to strip from the servers' host name
#
# Credit:
#
# The code below is knocked togther from ideas in...
#   * http://railstips.org/blog/archives/2011/03/21/hi-my-name-is-john/
#   * http://www.mikeperham.com/2012/08/25/using-statsd-with-rails/
#   * http://37signals.com/svn/posts/3091-pssst-your-rails-application-has-a-secret-to-tell-you
#
# Notes:
#
#   Uses ActiveSupport::Notifications to hook in some instrumentation...
#   @see http://guides.rubyonrails.org/active_support_instrumentation.html
#
ActiveSupport::Notifications.subscribe /process_action.action_controller/ do |*args|
  event      = ActiveSupport::Notifications::Event.new(*args)
  controller = event.payload[:controller].gsub('Controller', '_controller').gsub('::', '.')
  action     = event.payload[:action]
  format     = event.payload[:format]
  format     = 'other' unless %i(html json xml ris csv).include?(format)
  status     = event.payload[:status].to_i
  status     = '5xx' if status >= 500 && status <= 599
  hostname   = Socket.gethostname.downcase
  hostname   = hostname.gsub(ENV['STRIP_DOMAIN_FROM_HOST'], '') if ENV['STRIP_DOMAIN_FROM_HOST']
  key        = "controllers.#{controller}.#{action}.#{format}".downcase

  # count reponses
  $statsd.increment('http_status.overall')
  $statsd.increment("http_status.#{status}")
  $statsd.increment("#{key}.http_status.#{status}")
  $statsd.increment("#{key}.#{hostname}.http_status.#{status}")

  # only record timings on success
  if status == 200
    $statsd.timing('response_time', event.duration)

    $statsd.timing("#{key}.response_time", event.duration)
    $statsd.timing("#{key}.db_time", event.payload[:db_runtime])
    $statsd.timing("#{key}.view_time", event.payload[:view_runtime])

    $statsd.timing("#{key}.#{hostname}.response_time", event.duration)
    $statsd.timing("#{key}.#{hostname}.db_time", event.payload[:db_runtime])
    $statsd.timing("#{key}.#{hostname}.view_time", event.payload[:view_runtime])
  end
end
