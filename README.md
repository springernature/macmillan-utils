# Macmillan::Utils

A collection of useful patterns we use in our Ruby applications.

## Installation

Add this line to your application's Gemfile:

    gem 'macmillan-utils', require: false

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install macmillan-utils

## Usage

### RSpec Helpers

Add the following to your `spec_helper.rb` get our default RSpec setup:

    require 'macmillan/utils/rspec/rspec_defaults'
    require 'macmillan/utils/rspec/codeclimate_helper'
    require 'macmillan/utils/rspec/simplecov_helper'
    require 'macmillan/utils/rspec/webmock_helper'

## Contributing

1. Fork it ( https://github.com/[my-github-username]/macmillan-utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
