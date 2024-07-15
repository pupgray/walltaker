json.set! '@context', ["https://www.w3.org/ns/activitystreams", "https://w3id.org/security/v1"]
json.id actor_url(@user.username)
json.type "Person"
json.name "#{@user.username}'s wallpaper"
json.summary "An automated account to track #{@user.username}'s current wallpaper.'"
json.manuallyApprovesFollowers false
json.discoverable true
json.published @user.created_at
json.preferredUsername @user.username
json.url user_url(@user.username)
json.inbox actor_activity_pub_message_index_url(actor_id: @user.username)
json.outbox "https://example.com/inbox"
json.followers actor_follower_url(actor_id: @user.username)
json.following actor_follower_url(actor_id: @user.username)
json.publicKey do
  json.id actor_url(@user.username, anchor: 'main-key')
  json.owner actor_url(@user.username)
  json.publicKeyPem @public_key
end