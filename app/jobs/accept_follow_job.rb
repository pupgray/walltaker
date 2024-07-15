class AcceptFollowJob < ApplicationJob
  queue_as :default

  def perform(actor, id, user,  key_path)
    actor_response = Excon.get(actor, headers: { 'Accept': 'application/activity+json' })
    inbox = JSON.parse(actor_response.body)['inbox']
    document = JSON.dump({
                           "@context": "https://www.w3.org/ns/activitystreams",
                           "type": "Accept",
                           "actor": user,
                           "object": id
                         })
    sha256 = OpenSSL::Digest::SHA256.new
    digest = "SHA-256=" + Base64.strict_encode64(sha256.digest(document))
    date = Time.now.utc.httpdate
    keypair = OpenSSL::PKey::RSA.new(Key.find_by_purpose(:activity_pub).private)
    signed_string = "(request-target): post /inbox\nhost: mastodon.social\ndate: #{date}\ndigest: #{digest}"
    signature = Base64.strict_encode64(keypair.sign(OpenSSL::Digest::SHA256.new, signed_string))
    header = 'keyId="' + key_path + '",headers="(request-target) host date digest",signature="' + signature + '"'
    result = Excon.post(inbox, body: document, headers: { 'Content-Type': 'application/activity+json', 'Host': URI.parse(inbox).host, 'Date': date, 'Signature': header, 'Digest': digest })
    logger.fatal "GUH!!!!" + result.body
  end
end
