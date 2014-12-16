require 'rack/test'

module RackTestHelper
  def req_for(url, opts = {})
    Rack::Request.new(env_for(url, opts))
  end

  def env_for(url, opts = {})
    Rack::MockRequest.env_for(url, opts)
  end
end
include RackTestHelper
