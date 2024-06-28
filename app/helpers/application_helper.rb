module ApplicationHelper
  include Pagy::Frontend

  def has_requests?
    return Friendship.all.where(receiver_id: current_user.id, confirmed: false).count.positive? if current_user

    false
  end

  def is_surrender_controller_session?
    cookies.signed[:surrender_id].present?
  end
end
