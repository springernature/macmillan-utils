require 'rspec'

RSpec.configure do |config|
  config.order = 'random'

  # Exit the suite on the first failure
  config.fail_fast = true if ENV['FAIL_FAST']
end
