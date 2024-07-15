json.set! '@context', ["https://www.w3.org/ns/activitystreams", "https://w3id.org/security/v1"]
json.id actor_url(@user.username)
json.type "Person"
json.preferredUsername "#{@user.username}'s wallpaper"
json.inbox "https://example.com/inbox"
json.followers actor_follower_url(actor_id: @user.username)
json.following actor_follower_url(actor_id: @user.username)
json.publicKey do
  json.id actor_url(@user.username, anchor: 'main-key')
  json.owner actor_url(@user.username)
  json.publicKeyPem @public_key
end