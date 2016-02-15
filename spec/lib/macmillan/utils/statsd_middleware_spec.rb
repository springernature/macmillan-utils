require 'spec_helper'

describe Macmillan::Utils::StatsdMiddleware do
  let(:app)           { ->(env) { [200, env, 'app'] } }
  let(:request)       { req_for('http://example.com') }
  let(:statsd_client) { spy(:statsd_client) }

  subject { Macmillan::Utils::StatsdMiddleware.new(app, client: statsd_client) }

  it 'sends an increment metric for the status_code' do
    subject.call(request.env)
    expect(statsd_client).to have_received(:increment).with('rack.http_status.request.200').once
  end

  it 'sends an increment metric for all requests' do
    subject.call(request.env)
    expect(statsd_client).to have_received(:increment).with('rack.increments.request').once
  end

  it 'sends a timing metric for all requests' do
    subject.call(request.env)
    expect(statsd_client).to have_received(:timing).with('rack.timers.request', anything).once
  end

  context 'when extra metrics have been pushed into the env' do
    let(:app) do
      lambda do |env|
        env['statsd.timers']     << 'foo.bar'
        env['statsd.increments'] << 'woo.waa'

        [200, env, 'app']
      end
    end

    it 'sends these to statsd' do
      subject.call(request.env)
      expect(statsd_client).to have_received(:timing).with('rack.timers.foo.bar', anything).once
      expect(statsd_client).to have_received(:increment).with('rack.increments.woo.waa').once
      expect(statsd_client).to have_received(:increment).with('rack.http_status.woo.waa.200').once
    end
  end

  context 'upon error' do
    let(:app) { ->(_env) { raise } }

    it 'sends an exception increment to statsd and raises the error' do
      expect { subject.call(request.env) }.to raise_error(RuntimeError)
      expect(statsd_client).to have_received(:increment).with('rack.exception').once
    end
  end
end
