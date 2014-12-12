require 'spec_helper'

describe Macmillan::Utils::StatsdMiddleware do
  let(:app)           { ->(env) { [200, env, 'app'] } }
  let(:request)       { req_for('http://example.com') }
  let(:statsd_client) { spy(:statsd_client) }

  subject { Macmillan::Utils::StatsdMiddleware.new(app, client: statsd_client) }

  it 'sends an increment metric for the status_code' do
    subject.call(request.env)
    expect(statsd_client).to have_received(:increment).with('rack.request.status_code.200').once
  end

  it 'sends an increment metric for all requests' do
    subject.call(request.env)
    expect(statsd_client).to have_received(:increment).with('rack.request').once
  end

  it 'sends a timing metric for all requests' do
    subject.call(request.env)
    expect(statsd_client).to have_received(:timing).with('rack.request', anything).once
  end

  context 'when extra metrics have been pushed into the env' do
    let(:app) do
      ->(env) do
        env['statsd.timers']     << 'foo.bar'
        env['statsd.increments'] << 'woo.waa'

        [200, env, 'app']
      end
    end

    it 'sends these to statsd' do
      subject.call(request.env)
      expect(statsd_client).to have_received(:timing).with('rack.foo.bar', anything).once
      expect(statsd_client).to have_received(:increment).with('rack.woo.waa').once
      expect(statsd_client).to have_received(:increment).with('rack.woo.waa.status_code.200').once
    end
  end

  context 'upon error' do
    let(:app) { ->(env) { raise } }

    it 'sends an exception increment to statsd and raises the error' do
      expect { subject.call(request.env) }.to raise_error
      expect(statsd_client).to have_received(:increment).with('rack.exception').once
    end
  end
end
