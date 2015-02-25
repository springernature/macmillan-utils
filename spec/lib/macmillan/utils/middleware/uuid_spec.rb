require 'spec_helper'

RSpec.describe Macmillan::Utils::Middleware::Uuid do
  let(:app)             { ->(env) { [200, env, 'app'] } }
  let(:request)         { req_for('http://example.com') }
  let(:user)            { double(email: 'bob.flemming@cough.com', user_id: '12345') }
  let(:user_uuid)       { Digest::SHA1.hexdigest(user.user_id.to_s) }

  subject { Macmillan::Utils::Middleware::Uuid.new(app) }

  context 'when we have a logged in user' do
    before do
      request.env['current_user'] = user
    end

    context 'who has not visited before' do
      it 'sets the user_uuid cookie' do
        _status, headers, _body = subject.call(request.env)
        expect(headers['Set-Cookie']).to include(user_uuid)
      end

      it 'stores the user_uuid in the env' do
        _status, headers, _body = subject.call(request.env)
        expect(headers['user.uuid']).to eq(user_uuid)
      end
    end

    context 'who also has a randomly assigned user_uuid cookie (from a previous non-authenticated session)' do
      before do
        request.cookies['user.uuid'] = 'qwerty'
      end

      it 'replaces this cookie with one based on the users user_id' do
        _status, headers, _body = subject.call(request.env)
        expect(headers['Set-Cookie']).to include("user.uuid=#{user_uuid}")
      end
    end
  end

  context 'when we have a non-logged in user' do
    before do
      request.env['current_user'] = nil
      allow(SecureRandom).to receive(:uuid).and_return('wibble')
    end

    context 'who has not visited before' do
      it 'stores the auto-generated UUID in the env' do
        _status, headers, _body = subject.call(request.env)
        expect(headers['user.uuid']).to eq('wibble')
      end

      it 'sets the user_uuid cookie' do
        _status, headers, _body = subject.call(request.env)
        expect(headers['Set-Cookie']).to include('user.uuid=wibble')
      end
    end

    context 'who has visited before and has a user_uuid cookie' do
      before do
        request.cookies['user.uuid'] = 'qwerty'
      end

      it 'stores the user_uuid (from the cookie) in the env' do
        _status, headers, _body = subject.call(request.env)
        expect(headers['user.uuid']).to eq('qwerty')
      end

      it 'does not try to replace the cookie' do
        _status, headers, _body = subject.call(request.env)
        expect(headers['Set-Cookie']).to be_nil
      end
    end
  end
end
