require 'spec_helper'
require 'macmillan/utils/logger/factory'
require 'macmillan/utils/logger/formatter'

describe Macmillan::Utils::Logger::Formatter do
  let(:msg)    { 'testing' }
  let(:prefix) { nil }
  let(:target) { File.open('/dev/null', 'w+') }

  subject { Macmillan::Utils::Logger::Formatter.new(prefix) }

  let(:logger) do
    log = Macmillan::Utils::Logger::Factory.build_logger(:logger, target: target)
    log.formatter = subject
    log
  end

  describe '#call' do
    it 'is called by the logger object' do
      expect(target).to receive(:write).once
      expect(subject).to receive(:call).once
      logger.info 'this is a test'
    end

    context 'when a prefix is set' do
      let(:prefix) { 'WEEEE' }

      it 'is put in front of the log message' do
        expect(target).to receive(:write).with("#{prefix} [ INFO]: #{msg}\n").once
        logger.info msg
      end
    end

    context 'when the log message is a string' do
      it 'returns the string' do
        expect(target).to receive(:write).with("[ INFO]: #{msg}\n").once
        logger.info msg
      end
    end

    context 'when the log message is an exception' do
      it 'returns full details of the exception' do
        ex = StandardError.new("qwerty")
        expect(ex).to receive(:message).once
        expect(ex).to receive(:class).once
        expect(ex).to receive(:backtrace).once

        logger.info ex
      end
    end

    context 'when the log message is NOT a string or exception' do
      it 'retuns object.inspect' do
        ex = Array.new
        expect(ex).to receive(:inspect).once

        logger.info ex
      end
    end
  end
end
