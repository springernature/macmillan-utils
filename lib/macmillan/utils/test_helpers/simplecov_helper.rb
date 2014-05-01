if ENV['USE_SIMPLECOV']
  require 'simplecov'
  require 'simplecov-rcov'

  formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter
  ]

  if ENV['CODECLIMATE_REPO_TOKEN']
    require 'codeclimate-test-reporter'
    formatters << CodeClimate::TestReporter::Formatter
  end

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]

  unless ENV['DO_NOT_START_SIMPLECOV']
    mode = nil
    mode = 'rails' if ENV['RAILS_ENV']

    SimpleCov.start mode do
      load_profile 'test_frameworks'
      merge_timeout 3600
    end
  end
end
