class FollowersController < ApplicationController
  before_action :set_default_response_format

  def show
    @user = User.find_by_username(params[:actor_id])

    render content_type: 'application/activity+json'
  end

  private

  def set_default_response_format
    request.format = :json
  end
end
