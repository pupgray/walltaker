# frozen_string_literal: true
class Rack::Attack
  throttle('req/ip', limit: 250, period: 1.minute) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  throttle('link_pings/ip', limit: 3, period: 10.seconds) do |req|
    (req.ip + req.path) if req.path.match?(/^\/links\/\d+\.json/) || req.path.match?(/^\/api\/links\/\d+\.json/)
  end

  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/session' && req.post?
      req.ip
    end
  end
end