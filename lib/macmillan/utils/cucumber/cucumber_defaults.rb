require 'cucumber'
require 'multi_test'

# control rogue test/unit/autorun requires
MultiTest.disable_autorun

# exit the suite after the first failure
if ENV['FAIL_FAST']
  After do |scenario|
    Cucumber.wants_to_quit = true if scenario.failed?
  end
end
