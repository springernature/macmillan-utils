require 'spec_helper'

describe Macmillan::Utils::Settings do
  let(:finder) { Macmillan::Utils::Settings.instance }

  it 'lookups variables from the local environent' do
    ENV['FOO'] = 'bar'
    var = finder.lookup 'foo'
    expect(var).to eql 'bar'
  end

  it 'lookups variables from the local application yml' do
    fixtures_dir = File.expand_path('../../../../fixtures', __FILE__)
    Dir.chdir fixtures_dir do
      var = finder.lookup 'process_pid'
      expect(var).to eql(Process.pid.to_i)
    end
  end
end
