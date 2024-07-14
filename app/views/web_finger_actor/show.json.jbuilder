json.subject "acct:#{@user.username}@#{request.host}"

json.links do
  json.child! do
    json.rel "self"
    json.type "application/activity+json"
    json.href actor_url(@user.username)
  end
end