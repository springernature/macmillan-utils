require 'spec_helper'

describe Macmillan::Utils::Middleware::WeakEtags do
  let(:etag)  { 'W/"qwerty"' }
  let(:app)   { ->(env) { [200, env, 'app'] } }

  let(:request) do
    req = req_for('http://example.com')
    req.env['HTTP_IF_NONE_MATCH'] = etag
    req
  end

  subject { Macmillan::Utils::Middleware::WeakEtags.new(app) }

  context 'when using Weak ETags' do
    it 'removes the "W/" from the header' do
      _status, headers, _body = subject.call(request.env)
      expect(headers['HTTP_IF_NONE_MATCH']).to eq('"qwerty"')
    end
  end

  context 'when using Strong ETags' do
    let(:etag) { '"qwerty"' }

    it 'does not modify the header' do
      _status, headers, _body = subject.call(request.env)
      expect(headers['HTTP_IF_NONE_MATCH']).to eq('"qwerty"')
    end
  end
end
