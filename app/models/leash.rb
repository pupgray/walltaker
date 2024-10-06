class Leash < ApplicationRecord
  belongs_to :friendship
  belongs_to :master, class_name: 'User'
  belongs_to :pet, class_name: 'User'

  validates_associated :friendship
  validate :only_one_master_per_pet, on: :create
  validate :friendship_must_be_confirmed
  validates :pet, uniqueness: { scope: :master }
  validates :friendship, uniqueness: { message: 'was already used in a leash. Are you already a pet/master?' }

  scope :held_by, ->(user) { where(master: user) }
  scope :leashing, ->(user) { where(pet: user) }

  def only_one_master_per_pet
    errors.add(:pet, "already has master #{master.username}.") if Leash.leashing(pet).first&.valid?
  end

  def friendship_must_be_confirmed
    errors.add(:friendship, "is not confirmed.") unless friendship.confirmed?
  end
end
