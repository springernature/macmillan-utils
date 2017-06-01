require 'spec_helper'

RSpec.describe Macmillan::Utils::Middleware::Uuid do
  let(:app)             { ->(_env) { app_return } }
  let(:app_return)      { [200, {}, ['app']] }
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
        expect(app).to receive(:call).with(hash_including('user.uuid' => user_uuid)).and_return(app_return)
        _status, _headers, _body = subject.call(request.env)
      end

      it 'tells following rack app the user_uuid is new' do
        expect(app).to receive(:call).with(hash_including('user.uuid_is_new' => true)).and_return(app_return)
        _status, _headers, _body = subject.call(request.env)
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

      it 'uses httponly cookie' do
        _status, headers, _body = subject.call(request.env)
        expect(headers['Set-Cookie']).to match(/httponly/i)
      end

      it 'tells following rack app the user_uuid is new' do
        expect(app).to receive(:call).with(hash_including('user.uuid_is_new' => true)).and_return(app_return)
        _status, _headers, _body = subject.call(request.env)
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
        expect(app).to receive(:call).with(hash_including('user.uuid' => 'wibble')).and_return(app_return)
        _status, _headers, _body = subject.call(request.env)
      end

      it 'sets the user_uuid cookie' do
        _status, headers, _body = subject.call(request.env)
        expect(headers['Set-Cookie']).to include('user.uuid=wibble')
      end

      it 'uses httponly cookie' do
        _status, headers, _body = subject.call(request.env)
        expect(headers['Set-Cookie']).to match(/httponly/i)
      end

      it 'tells following rack app the user_uuid is new' do
        expect(app).to receive(:call).with(hash_including('user.uuid_is_new' => true)).and_return(app_return)
        _status, _headers, _body = subject.call(request.env)
      end
    end

    context 'who has visited before and has a user_uuid cookie' do
      before do
        request.cookies['user.uuid'] = 'qwerty'
      end

      it 'stores the user_uuid (from the cookie) in the env' do
        expect(app).to receive(:call).with(hash_including('user.uuid' => 'qwerty')).and_return(app_return)
        _status, _headers, _body = subject.call(request.env)
      end

      it 'does not try to replace the cookie' do
        _status, headers, _body = subject.call(request.env)
        expect(headers['Set-Cookie']).to be_nil
      end

      it 'does not tell following rack app the user_uuid is new' do
        expect(app).to receive(:call) do |args|
          expect(args).not_to have_key('user.uuid_is_new')
        end.and_return(app_return)
        _status, _headers, _body = subject.call(request.env)
      end
    end
  end
end
