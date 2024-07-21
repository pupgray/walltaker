# frozen_string_literal: true
class Rack::Attack
  throttle('req/ip', limit: 300, period: 1.minute) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/session' && req.post?
      req.ip
    end
  end
end