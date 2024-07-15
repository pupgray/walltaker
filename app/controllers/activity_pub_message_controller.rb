class ActivityPubMessageController < ApplicationController
  before_action :set_default_response_format

  def create

    render content_type: 'application/jrd+json'
  end

  private

  def set_default_response_format
    request.format = :json
  end
end
