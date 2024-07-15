json.subject "acct:#{@user.username}@#{request.host}"

json.links do
  json.child! do
    json.rel "self"
    json.type "application/activity+json"
    json.href actor_url(@user.username)
  end
  json.child! do
    json.rel "http://webfinger.net/rel/avatar"
    json.type "image/png"
    json.href image_url("mascot/#{@user.mascot&.capitalize || 'Ki'}Head.png")
  end
  json.child! do
    json.rel "http://webfinger.net/rel/profile-page"
    json.type "text/html"
    json.href user_url(@user.username)
  end
end