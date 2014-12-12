require 'webmock/cucumber'

Before do
  WebMock.disable_net_connect!(allow_localhost: true, allow: [/capybara-local/, /codeclimate/])
end

After do
  WebMock.reset!
end
