require 'rspec'

RSpec.configure do |config|
  config.order = 'random'

  # Exit the suite on the first failure
  if ENV['FAIL_FAST']
    config.fail_fast = true
  end
end
