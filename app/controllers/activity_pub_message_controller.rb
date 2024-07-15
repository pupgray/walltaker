class ActivityPubMessageController < ApplicationController
  before_action :set_default_response_format
  protect_from_forgery with: :null_session

  def create
    type = parsed_body['type']
    user = User.find_by_username(params[:actor_id])
    actor = parsed_body['actor']

    case type
    when 'Follow'
      ApFollower.create(user:, url: actor)
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
