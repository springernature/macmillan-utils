require 'spec_helper'

describe Macmillan::Utils::Logger::Factory do
  describe '#build_logger' do
    context 'for a syslog logger' do
      subject { Macmillan::Utils::Logger::Factory.build_logger(:syslog, tag: 'myapp', facility: 2) }

      it 'returns a Logger::Syslog object' do
        expect(subject).to be_an_instance_of(Logger::Syslog)
      end

      it 'allows you to configure the syslog tag and facility' do
        expect(Logger::Syslog).to receive(:new).with('myapp', Syslog::LOG_LOCAL2).and_call_original
        subject
      end

      it 'aliases logger#write to logger#info' do
        expect(subject).to respond_to(:write)
      end
    end

    context 'for a standard Logger' do
      subject { Macmillan::Utils::Logger::Factory.build_logger(:logger) }

      it 'returns a Logger object' do
        expect(subject).to be_an_instance_of(Logger)
      end

      it 'logs to STDOUT by default' do
        expect(Logger).to receive(:new).with($stdout).and_call_original
        subject
      end

      it 'allows you to configure the log target' do
        expect(Logger).to receive(:new).with('foo.log').and_call_original
        Macmillan::Utils::Logger::Factory.build_logger(:logger, target: 'foo.log')
      end
    end

    context 'for a null logger' do
      subject { Macmillan::Utils::Logger::Factory.build_logger(:null) }

      it 'returns a Logger object' do
        expect(subject).to be_an_instance_of(Logger)
      end

      it 'builds a logger object that points to /dev/null' do
        expect(Logger).to receive(:new).with('/dev/null').and_call_original
        subject
      end
    end
  end
end
