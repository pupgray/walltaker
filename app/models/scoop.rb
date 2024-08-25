class Scoop < ApplicationRecord
  belongs_to :user
  belongs_to :link, optional: true

  validates :details, presence: true
  validate :user_has_waited_long_enough, on: :create
  validate :not_editing_shown_scoop, on: :update

  def interview_image_url
    case user.mascot
    when 'ki', nil
      'mascot/news/KiInterviewOpen.png'
    when 'taylor'
      'mascot/news/TaylorInterviewOpen.png'
    when 'warren'
      'mascot/news/WarrenInterviewOpen.png'
    else
      ''
    end
  end

  private

  def user_has_waited_long_enough
    errors.add(:user, 'already posted a scoop within the last week!') if user.scoops.where('created_at > ?', 7.days.ago).exists?
  end

  def not_editing_shown_scoop
    errors.add(:base, 'Scoop was already shown. It can no longer be changed.') if was_shown_was == true
  end
end
