require 'spec_helper'

describe Macmillan::Utils::StatsdControllerHelper do
  let(:request)    { req_for('http://example.com') }
  let(:timers)     { [] }
  let(:increments) { [] }

  class TestSubject
    attr_accessor :request

    include Macmillan::Utils::StatsdControllerHelper
  end

  subject { TestSubject.new }

  before do
    subject.request = request
    request.env[::Macmillan::Utils::StatsdMiddleware::TIMERS] = timers
    request.env[::Macmillan::Utils::StatsdMiddleware::INCREMENTS] = increments
  end

  describe '#add_statsd_timer' do
    it 'adds a key to the correct env variable' do
      subject.send(:add_statsd_timer, 'woo')
      expect(request.env[::Macmillan::Utils::StatsdMiddleware::TIMERS]).to eq(['woo'])
    end
  end

  describe '#add_statsd_increment' do
    it 'adds a key to the correct env variable' do
      subject.send(:add_statsd_increment, 'waa')
      expect(request.env[::Macmillan::Utils::StatsdMiddleware::INCREMENTS]).to eq(['waa'])
    end
  end

  describe '#add_statsd_timer_and_increment' do
    it 'adds a key to both env variables' do
      subject.send(:add_statsd_timer_and_increment, 'wee')
      expect(request.env[::Macmillan::Utils::StatsdMiddleware::TIMERS]).to eq(['wee'])
      expect(request.env[::Macmillan::Utils::StatsdMiddleware::INCREMENTS]).to eq(['wee'])
    end
  end
end
