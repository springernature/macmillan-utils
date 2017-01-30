lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'macmillan-utils'
  spec.version       = "1.0.#{ENV['TRAVIS_BUILD_NUMBER'] || ENV['BUILD_NUMBER'] || 'dev'}"
  spec.authors       = ['Springer Nature']
  spec.email         = ['npp-developers@macmillan.com']
  spec.summary       = 'A collection of useful patterns we (Springer Nature) use in our Ruby applications.'
  spec.homepage      = 'https://github.com/springernature/macmillan-utils'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rack', '< 2.0.0'

  spec.add_dependency 'rspec'
  spec.add_dependency 'simplecov'
  spec.add_dependency 'simplecov-rcov'
  spec.add_dependency 'codeclimate-test-reporter'
  spec.add_dependency 'webmock'
  spec.add_dependency 'multi_test'
  spec.add_dependency 'syslog-logger'
  spec.add_dependency 'rubocop'
  spec.add_dependency 'colorize'
end
