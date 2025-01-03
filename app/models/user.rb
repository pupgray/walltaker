class User < ApplicationRecord
  include ActiveModel::SecurePassword
  has_secure_password
  has_many :link, dependent: :destroy
  has_many :history_events, dependent: :destroy
  has_many :past_links, foreign_key: :set_by_id
  has_many :orgasms, foreign_key: :user_id, class_name: 'Nuttracker::Orgasm'
  has_many :caused_orgasms, foreign_key: :caused_by_user_id, class_name: 'Nuttracker::Orgasm'
  has_many :notifications
  has_many :ahoy_visits, :class_name => 'Ahoy::Visit'
  has_many :kink_havers
  has_many :kinks, -> { order(id: :desc) }, through: :kink_havers
  attribute :colour_preference, :integer
  belongs_to :viewing_link, foreign_key: :viewing_link_id, class_name: 'Link', optional: true
  has_many :message_thread_participants
  has_many :message_threads, through: :message_thread_participants
  has_many :messages, through: :message_threads
  has_many :reports, as: :reportable
  has_many :profiles, inverse_of: :user
  has_many :friendships, ->(user) { unscope(:where).where(receiver_id: user.id).or(where(sender_id: user.id)) }
  has_many :held_leashes, ->(user) { where(master: user) }, through: :friendships, source: :leashes
  has_many :obeying_leashes, ->(user) { where(pet: user) }, through: :friendships, source: :leashes
  has_many :pets, through: :held_leashes
  has_many :masters, through: :obeying_leashes
  belongs_to :profile, optional: true
  has_one :current_surrender, class_name: 'Surrender', dependent: :destroy
  has_many :scoops
  has_one :nut_pledge, dependent: :destroy

  validates_uniqueness_of :username

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
                              message: 'must be a valid email address' }
  validates_uniqueness_of :email, :case_sensitive => false
  validates :password, confirmation: true
  validates :username, presence: true, format: { with: /\A[a-zA-Z0-9]+\Z/ }

  enum colour_preference: %i[auto light dark]

  scope :has_friendship_with, ->(other) {
    Friendship.find_friendship(other, self)
  }

  scope :controllable_by, ->(other) {
    controllable_user_ids = other.controllable_surrenders.pluck(:user_id).uniq
    where(id: controllable_user_ids)
  }

  def master
    masters.first || nil
  end

  def flair
    obeying_leashes.first&.flair || nil
  end

  # This was implemented so bad lol, should've been a relation.
  def find_pornlizard
    case mascot
    when 'taylor'
      User.find_by_username('PornLizardTaylor')
    when 'warren'
      User.find_by_username('PornLizardWarren')
    when 'ki'
      User.find_by_username('PornLizardKi')
    else
      User.find_by_username('PornLizardKi')
    end
  end

  def details
    return profile.content if profile
    profiles.order(id: :asc).first&.content || ''
  end

  def current_profile_name
    return profile.name || 'Unnamed' if profile
    '<Imported Profile>'
  end

  def assign_new_api_key
    self.api_key = SecureRandom.base64(6).slice 0..7
    save
  end

  def view_link(link)
    self.viewing_link_id = link.id
    save
  end

  def leave_link
    self.viewing_link_id = nil
    save
  end

  def controllable_surrenders
    friendship_ids = Friendship.involving(self).is_confirmed.pluck(:id)
    Surrender.not_for_user(self).where(id: friendship_ids)
  end

  def snapshot
    <<~OUT.strip
      #{username}
      #{details}

      Recent messages:
      #{messages.limit(6).map { |message| "=> (to #{message.message_thread&.users&.map(&:username).join(',')}) #{message.content}" }.join("\n")}

      Recent wallpapers set for others:
      #{past_links.limit(6).map { |pl| "=> (for #{pl.link&.user&.username} on ##{pl.link&.id}) #{pl.post_url}" }.join("\n")}

      All links:

      ======= LINK ========
      #{link.map(&:snapshot).join("\n\n======= LINK ========\n")}
    OUT
  end

  def to_s
    username
  end

  after_commit do
    if viewing_link_id
      viewed_link = Link.find(viewing_link_id)
    elsif viewing_link_id_before_last_save
      viewed_link = Link.find(viewing_link_id_before_last_save)
    end

    if viewed_link
      users_viewing_links = User.where.not(viewing_link_id: nil)
      broadcast_replace_to "link_viewing_users_#{viewed_link.id}", target: "link_viewing_users_#{viewed_link.id}", partial: 'links/viewing_users', locals: { link: viewed_link }
      broadcast_replace_to "dashboard_users_viewing_links", target: "users_viewing_links", partial: 'dashboard/users_viewing_links', locals: { users_viewing_links: }
    end
  end
end
