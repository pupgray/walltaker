class ActivityPubMessageController < ApplicationController
  before_action :set_default_response_format
  protect_from_forgery with: :null_session

  def create
    type = parsed_body['type']
    user = User.find_by_username(params[:actor_id])
    id = parsed_body['id']
    actor = parsed_body['actor']

    case type
    when 'Follow'
      ApFollower.create(user:, url: actor)
      actor_response = Excon.get(actor)
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
      header = 'keyId="' + actor_url(user.username, anchor: 'main-key') + '",headers="(request-target) host date digest",signature="' + signature + '"'

      Excon.post(inbox, body: document, headers: { 'Content-Type': 'application/activity+json', 'Date': date, 'Signature': header, 'Digest': digest })
    end

    render content_type: 'application/jrd+json'
  end

  private

  def parsed_body
    JSON.parse(request.raw_post)
  end

  def set_default_response_format
    request.format = :json
  end
end
