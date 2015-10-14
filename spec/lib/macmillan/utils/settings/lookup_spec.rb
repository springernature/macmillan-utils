require 'spec_helper'

describe Macmillan::Utils::Settings::Lookup do
  let(:backend1) { double('Backend One') }
  let(:backend2) { double('Backend Two') }

  subject { described_class.new([backend1, backend2]) }

  it 'returns the first value it finds' do
    true_value = Macmillan::Utils::Settings::Value.new('is_craigw_trolling_us', true, backend1, 'is_craigw_trolling_us')
    allow(backend1).to receive(:get).with('is_craigw_trolling_us').and_return(true_value)

    expect(backend2).to_not receive(:get)
    expect(subject.lookup('is_craigw_trolling_us')).to eq(true)
  end

  it 'tries successive backends' do
    not_found_value = Macmillan::Utils::Settings::KeyNotFound.new('is_craigw_trolling_us', backend1, 'is_craigw_trolling_us')
    true_value = Macmillan::Utils::Settings::Value.new('is_craigw_trolling_us', true, backend2, 'is_craigw_trolling_us')

    allow(backend1).to receive(:get).with('is_craigw_trolling_us').and_return(not_found_value)
    allow(backend2).to receive(:get).with('is_craigw_trolling_us').and_return(true_value)

    expect(subject.lookup('is_craigw_trolling_us')).to eq(true)
  end

  it 'returns a falsey value if it is actually set' do
    not_found_value = Macmillan::Utils::Settings::KeyNotFound.new('is_it_good_code', backend1, 'is_it_good_code')
    false_value = Macmillan::Utils::Settings::Value.new('is_it_good_code', false, backend2, 'is_it_good_code')

    allow(backend1).to receive(:get).with('is_it_good_code').and_return(not_found_value)
    allow(backend2).to receive(:get).with('is_it_good_code').and_return(false_value)

    expect(subject.lookup('is_it_good_code')).to eq(false)
  end

  it 'raises an error if it cannot find a value in any backend' do
    not_found_value1 = Macmillan::Utils::Settings::KeyNotFound.new('not_found', backend1, 'not_found')
    not_found_value2 = Macmillan::Utils::Settings::KeyNotFound.new('not_found', backend2, 'not_found')

    allow(backend1).to receive(:get).with('not_found').and_return(not_found_value1)
    allow(backend2).to receive(:get).with('not_found').and_return(not_found_value2)

    expect { subject.lookup('not_found') }.to raise_error(Macmillan::Utils::Settings::KeyNotFoundError)
  end
end
