class LinksControllerBase < ApplicationController
  protected
  # Use callbacks to share common setup or constraints between actions.
  def set_link(link_id)
    if link_id.match?(/\D+/)
      @link = Link.find_by(custom_url: link_id)
    else
      @link = Link.find_by(id: link_id)
    end
  end

  def require_link
    if @link.nil?
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def set_past_link(past_link_id)
    if past_link_id.match?(/\d+/)
      @past_link = PastLink.find_by(id: past_link_id)
    end
  end

  def require_past_link
    if @past_link.nil?
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def past_link_belongs_to_user?
    @past_link.link.user == current_user
  end

  def link_is_expired_and_not_owned?
    is_expired = @link.never_expires ? false : @link.expires <= Time.now.utc
    is_expired && (current_user&.id != @link.user.id)
  end

  def protect_friends_only_links
    unless request.format == :json
      authorize if @link.friends_only

      unless current_user.nil?
        friendship_exists = Friendship.find_friendship(@link.user, current_user).exists?
        if @link.friends_only && !friendship_exists && (current_user.id != @link.user.id)
          return redirect_to root_url, alert: 'Not Authorized'
        end
      end
    end
  end
end
