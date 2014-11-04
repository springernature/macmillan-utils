require 'spec_helper'

describe Macmillan::Utils::StatsdDecorator do
  let(:statsd)    { double(:statsd) }
  let(:logger)    { double(:logger, debug: nil) }
  let(:env)       { 'development' }
  let(:stat_name) { 'wibble.flibble' }

  subject { Macmillan::Utils::StatsdDecorator.new(statsd, env, logger) }

  statsd_calls = {
    increment: nil,
    decrement: nil,
    count:     12,
    guage:     12,
    set:       12,
    timing:    12
  }

  statsd_calls.each do |method, method_args|
    describe "##{method}" do
      before do
        @args = [stat_name]
        @args << method_args if method_args
        @args << 1 # sample_rate
      end

      it 'should send a message to the logger' do
        expect(logger).to receive(:debug).once
        subject.public_send(method, *@args)
      end

      context 'when in the "production" environment' do
        let(:env) { 'production' }

        it 'will pass on messages to the statsd delegatee' do
          expect(statsd).to receive(method).with(*@args).once
          subject.public_send(method, *@args)
        end
      end

      context 'when in a non "production" environment' do
        it 'will not pass on messages to the statsd delegatee' do
          expect(statsd).to_not receive(method)
          subject.public_send(method, *@args)
        end
      end
    end
  end

  describe '#time' do
    it 'should require a block' do
      expect { subject.time(stat_name) }.to raise_error
    end

    it 'should call the block' do
      block_called = false

      subject.time(stat_name) do
        block_called = true
      end

      expect(block_called).to be(true)
    end

    it 'should return the output of the block' do
      expected = double
      actual   = subject.time(stat_name) { expected }
      expect(actual).to eq(expected)
    end

    it 'should send a message to the logger' do
      expect(logger).to receive(:debug).once
      subject.time(stat_name) { true }
    end

    context 'when in the "production" environment' do
      let(:env) { 'production' }

      it 'should send a #timing message to the statsd delegatee' do
        expect(statsd).to receive(:timing).once
        subject.time(stat_name) { true }
      end
    end

    context 'when in a non "production" environment' do
      it 'should not send a #timing message to the statsd delegatee' do
        expect(statsd).to_not receive(:timing)
        subject.time(stat_name) { true }
      end
    end
  end
end
