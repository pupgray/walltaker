json.set! '@context', ["https://www.w3.org/ns/activitystreams"]
json.summary "#{@user.username}'s followers"
json.type 'Collection'
json.totalItems @user.ap_followers.count
json.items @user.ap_followers.pluck(:url)