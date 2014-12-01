require 'spec_helper'

describe Macmillan::Utils::Settings do
  let(:env_vars_backend) { Macmillan::Utils::Settings::EnvVarsBackend.new }
  let(:app_yaml_backend) { Macmillan::Utils::Settings::AppYamlBackend.new }
  let(:backends)         { [env_vars_backend, app_yaml_backend] }

  subject { Macmillan::Utils::Settings::Lookup.new(backends) }

  it 'lookups variables from the local environment' do
    ENV['FOO'] = 'bar'
    var = subject.lookup 'foo'
    expect(var).to eql 'bar'
  end

  it 'raises an error if the lookup fails' do
    looker_upper = Macmillan::Utils::Settings::Lookup.new([env_vars_backend])

    expect do
      looker_upper.lookup 'baz'
    end.to raise_error(Macmillan::Utils::Settings::KeyNotFoundError)
  end

  context 'when using an application.yml file' do
    context 'and the file exists' do
      it 'lookups variables from the local application yml' do
        fixtures_dir = File.expand_path('../../../../fixtures', __FILE__)

        Dir.chdir(fixtures_dir) do
          var = subject.lookup 'process_pid'
          expect(var).to eql(1234)
        end
      end
    end

    context 'but the file does not exist' do
      it 'raises an appropriate error' do
        expect do
          subject.lookup 'wibble'
        end.to raise_error('cannot find application.yml')
      end
    end
  end
end
