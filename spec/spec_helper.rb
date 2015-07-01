$LOAD_PATH.unshift File.join(__FILE__, '../../lib')

require 'bundler'
Bundler.setup(:default, :test)

require 'macmillan/utils/rspec/rspec_defaults'
require 'macmillan/utils/rspec/rack_test_helper'
require 'macmillan/utils/test_helpers/codeclimate_helper'
require 'macmillan/utils/test_helpers/simplecov_helper'

require 'pry'
require 'syslog-logger'

require 'macmillan/utils'
