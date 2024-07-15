json.set! '@context', ["https://www.w3.org/ns/activitystreams"]
json.summary "#{@user.username}'s followers"
json.type 'Collection'
json.totalItems 0
json.items []