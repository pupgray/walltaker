class ActorController < ApplicationController
  before_action :set_default_response_format

  def show
    @user = User.find_by_username(params[:id])
    @public_key = Key.find_by_purpose(:activity_pub)&.public

    render content_type: 'application/jrd+json'
  end

  private

  def set_default_response_format
    request.format = :json
  end
end
