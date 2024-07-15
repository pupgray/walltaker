class WebFingerActorController < ApplicationController
  before_action :set_default_response_format

  def index
    resource_key = params[:resource]
    resource = resource_key.gsub('acct:', '') if resource_key
    username = resource.gsub(any_host, '') if resource
    @user = User.find_by(username: username) if username
    render  :show if @user

    render status: :not_found unless @user
  end

  def show
    @user = User.find_by_username(params[:id])

    render content_type: 'application/jrd+json'
  end

  private

  def set_default_response_format
    request.format = :json
  end

  def any_host
    targets = Rails.configuration.hosts.collect do |s|
      Regexp.escape("@#{s.to_s}")
    end.join('|')
    Regexp.new(targets)
  end
end
