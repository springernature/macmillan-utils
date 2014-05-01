require 'webmock/cucumber'

After do
  WebMock.reset!
end
