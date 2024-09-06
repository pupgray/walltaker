class Surrender < ApplicationRecord
  belongs_to :user, inverse_of: :current_surrender, required: true
  belongs_to :friendship, required: true

  validates :user, uniqueness: { scope: :friendship }
  validates :accepted_consequences, acceptance: true
  validates :expires_at, comparison: { greater_than: Time.now }
  validates :expires_at, comparison: { less_than_or_equal_to: Time.now + 2.weeks + 5.seconds }, on: :create
  validate :no_admin_surrendering, :friendship_is_confirmed

  scope :not_for_user, ->(user) { where.not(user: user) }
  scope :for_user, ->(user) { find_by(user: user) }

  after_update_commit -> { broadcast_replace target: :surrender_status, partial: 'layouts/surrender', locals: { surrender: self } }
  after_destroy_commit -> { broadcast_replace target: :surrender_status, partial: 'layouts/surrender', locals: { surrender: self } }

  def controller
    friendship.other_user(user)
  end

  def active?
    valid? && !pending?
  end

  private

  def no_admin_surrendering
    errors.add :user, 'cannot be an admin, think about that! That would give someone the admin tools!' if user.admin
  end

  def friendship_is_confirmed
    errors.add :friendship, 'must be accepted.' if !friendship.confirmed?
  end
end
