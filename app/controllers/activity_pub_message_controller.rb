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
      logger.debug "GUH! #{request.raw_post}"

      actor_response = Excon.get(actor, headers: { 'Accept': 'application/ld+json' })
      logger.debug "GUH!2 #{actor_response.body}"
      inbox = JSON.parse(actor_response.body)['inbox']
      document = JSON.dump({
                             "@context": "https://www.w3.org/ns/activitystreams",
                             "type": "Accept",
                             "actor": user,
                             "object": id
                           })
      logger.debug "GUH!3 #{document}"
      sha256 = OpenSSL::Digest::SHA256.new
      digest = "SHA-256=" + Base64.strict_encode64(sha256.digest(document))
      date = Time.now.utc.httpdate
      logger.debug "GUH!4 #{digest} ---- #{date}"
      keypair = OpenSSL::PKey::RSA.new(Key.find_by_purpose(:activity_pub).private)
      signed_string = "(request-target): post /inbox\nhost: mastodon.social\ndate: #{date}\ndigest: #{digest}"
      logger.debug "GUH!5 #{signed_string}"
      signature = Base64.strict_encode64(keypair.sign(OpenSSL::Digest::SHA256.new, signed_string))
      logger.info "GUH!6 #{inbox} #{actor_response.body}"
      header = 'keyId="' + actor_url(user.username, anchor: 'main-key') + '",headers="(request-target) host date digest",signature="' + signature + '"'
      logger.fatal "GUH!7 #{header}"

      result = Excon.post(inbox, body: document, headers: { 'Content-Type': 'application/activity+json', 'Host': URI.parse(inbox).host, 'Date': date, 'Signature': header, 'Digest': digest })
      logger.info "GUH!8 #{result.status} #{result.body}"

      render content_type: 'application/ld+json'
    end
  end

  private

  def parsed_body
    JSON.parse(request.raw_post)
  end

  def set_default_response_format
    request.format = :json
  end
end
