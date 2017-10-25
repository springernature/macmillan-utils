require 'spec_helper'

RSpec.describe Macmillan::Utils::Middleware::CookieMessage do
  let(:app) { ->(_) { [200, {}, %w[body]] } }
  let(:env) { env_for(url, request_headers) }
  let(:request_headers) { default_headers.merge(extra_headers) }
  let(:default_headers) { { 'REQUEST_METHOD' => request_method } }
  let(:extra_headers) { {} }

  subject { described_class.new(app) }

  let(:response) { subject.call(env) }
  let(:status) { response[0] }
  let(:headers) { response[1] }
  let(:body) { response[2] }
  let(:cookie) { headers['Set-Cookie'] }
  let(:location) { headers['Location'] }

  context 'when request params contains cookies=accepted' do
    let(:url) { 'http://www.nature.com/?cookies=accepted' }

    context 'and the request method is GET' do
      let(:request_method) { 'GET' }

      it 'calls the app' do
        expect(app).to receive(:call).with(env).and_call_original
        expect(response).to eq([200, {}, %w[body]])
      end
    end

    context 'and the request method is POST' do
      let(:request_method) { 'POST' }

      context 'and the euNoticeCookie is not set' do
        before do
          allow(Time).to receive(:now).and_return(Time.utc(2017, 1, 31))
          expect(app).not_to receive(:call)
        end

        it 'redirects' do
          expect(status).to eq(302)
        end

        it 'sets the cookie' do
          expect(cookie).to match(/euCookieNotice=accepted;/)
          expect(cookie).to match(/domain=\.nature\.com:80;/)
          expect(cookie).to match(%r{path=/;})
          expect(cookie).to match(/expires=Wed, 31 Jan 2018 00:00:00 -0000/)
          expect(cookie).to match(/httponly/i)
        end

        context 'and  the domain non-standard' do
          let(:url) { 'http://test-www.naturechina.com:5124/?cookies=accepted' }

          it 'sets the cookie' do
            expect(cookie).to match(/euCookieNotice=accepted;/)
            expect(cookie).to match(/domain=\.naturechina\.com:5124;/)
            expect(cookie).to match(%r{path=/;})
            expect(cookie).to match(/expires=Wed, 31 Jan 2018 00:00:00 -0000/)
            expect(cookie).to match(/httponly/i)
          end
        end

        it 'redirects back to the original url' do
          expect(location).to eq('http://www.nature.com/?cookies=accepted')
        end

        context 'and the referrer is set' do
          let(:extra_headers) { { 'HTTP_REFERER' => 'http://www.nature.com/articles/ncomms7169' } }

          it 'redirects back to the referrer' do
            expect(location).to eq('http://www.nature.com/articles/ncomms7169')
          end
        end
      end

      context 'and the euNoticeCookie is set' do
        let(:extra_headers) { { 'HTTP_COOKIE' => 'euCookieNotice=accepted' } }

        it 'calls the app' do
          expect(app).to receive(:call).with(env).and_call_original
          expect(response).to eq([200, {}, %w[body]])
        end
      end
    end
  end

  context 'when request params does not cookies=accepted' do
    let(:url) { 'http://www.nature.com/' }

    context 'and the request method is GET' do
      let(:request_method) { 'GET' }

      it 'calls the app' do
        expect(app).to receive(:call).with(env).and_call_original
        expect(response).to eq([200, {}, %w[body]])
      end
    end

    context 'and the request method is POST' do
      let(:request_method) { 'POST' }

      it 'calls the app' do
        expect(app).to receive(:call).with(env).and_call_original
        expect(response).to eq([200, {}, %w[body]])
      end
    end
  end

  describe 'logging' do
    let(:url) { 'http://www.nature.com/' }
    let(:request_method) { 'GET' }
    let(:output) { StringIO.new }

    matcher :have_output do |expected|
      match do
        expected === output(actual)
      end

      failure_message do |actual|
        "expected that #{output(actual)} would equal #{expected}"
      end

      def output(io)
        io.rewind && io.read
      end
    end

    context 'default logging' do
      subject { described_class.new(app) }

      around do |example|
        begin
          stdout = $stdout
          $stdout = output

          example.run
        ensure
          $stdout = stdout
        end
      end

      it 'produces no output' do
        expect(app).to receive(:call).with(env).and_call_original
        expect(response).to eq([200, {}, %w[body]])
        expect(output).to have_output('')
      end
    end

    context 'custom log level' do
      subject { described_class.new(app, log_level: ::Logger::DEBUG) }

      around do |example|
        begin
          stdout = $stdout
          $stdout = output

          example.run
        ensure
          $stdout = stdout
        end
      end

      it 'produces tagged output' do
        expect(app).to receive(:call).with(env).and_call_original
        expect(response).to eq([200, {}, %w[body]])
        expect(output).to have_output(/\[Macmillan::Utils::Middleware::CookieMessage\]/)
        expect(output).to have_output(/request.post\? \(false\) means passthru/)
      end
    end

    context 'custom logger that does not support tags' do
      let(:logger) { ::Logger.new(output) }

      subject { described_class.new(app, logger: logger) }

      it 'produces tagged output' do
        expect(app).to receive(:call).with(env).and_call_original
        expect(response).to eq([200, {}, %w[body]])
        expect(output).to have_output(/\[Macmillan::Utils::Middleware::CookieMessage\]/)
        expect(output).to have_output(/request.post\? \(false\) means passthru/)
      end
    end

    context 'custom logger that does not support tags - provided by Rack' do
      let(:extra_headers) do
        {
          'rack.logger' => ::Logger.new(output)
        }
      end

      subject { described_class.new(app) }

      it 'does not throw an error due to missing "tagged" def' do
        expect{ response }.not_to raise_error
      end

      it 'produces tagged output' do
        expect(app).to receive(:call).with(env).and_call_original
        expect(response).to eq([200, {}, %w[body]])
        expect(output).to have_output(/\[Macmillan::Utils::Middleware::CookieMessage\]/)
        expect(output).to have_output(/request.post\? \(false\) means passthru/)
      end
    end
  end
end
