class HistoryController < ApplicationController
  include LinkPermissionsChecks
  before_action :authorize, only: %i[update]

  # 2. set @link instance var, since a lot of action filters use it
  before_action do
    set_link(params[:link_id])
  end
  before_action :require_link
  before_action only: %i[show update] do
    set_past_link(params[:id])
  end
  before_action :show, only: %i[show]

  # 3. protect link-specific buisness rules
  before_action :past_link_matches_link, only: %i[show update]
  before_action :prevent_public_expired, if: -> { link_is_expired_and_not_owned? }
  before_action :skip_unauthorized_requests, only: %i[update], if: -> { !past_link_belongs_to_user? }
  before_action :protect_friends_only_links, only: %i[index show update]

  after_action :track_visit, only: %i[index show]

  def index
    @past_links = PastLink.all.order(id: :desc).where(link: @link).take(50)
  end

  def show
  end

  def update
    @past_link.set_reaction(past_link_params['response_type'], past_link_params['response_text'])
    redirect_to link_past_link_path(@link, @past_link)
  end

  def past_link_params
    params.require([:id, :response_type])
    return params.permit(:id, :response_type, :response_text)
  end

  def past_link_matches_link
    raise ActionController::RoutingError.new('Not Found') if @link != @past_link.link
  end

  def skip_unauthorized_requests
    track :nefarious, :edit_others_link
    redirect_to link_url(@link), alert: 'Not authorized.'
  end

  def prevent_public_expired
    redirect_to root_url, alert: 'That link has expired!'
  end

end
