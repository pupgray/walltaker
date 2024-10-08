class Link < ApplicationRecord
  include PgSearch::Model
  belongs_to :user
  belongs_to :set_by, foreign_key: :set_by_id, class_name: 'User', optional: true
  belongs_to :forked_from, foreign_key: :forked_from_id, class_name: 'Link', inverse_of: :forks, optional: true
  has_many :forks, foreign_key: :forked_from_id, class_name: 'Link', inverse_of: :forked_from, dependent: :nullify
  has_many :viewing_users, foreign_key: :viewing_link_id, class_name: 'User'
  has_many :past_links
  has_many :comments, dependent: :destroy
  has_many :abilities, class_name: 'LinkAbility', inverse_of: :link, dependent: :destroy
  has_many :users_viewing, class_name: 'User', foreign_key: :viewing_link_id, inverse_of: :viewing_link, dependent: :nullify
  enum response_type: %i[horny came disgust ok]
  validates :expires, presence: true, unless: :never_expires?
  validates :theme, format: { without: /\s+/i, message: 'must be only 1 tag.' }
  validates :theme, format: { without: /\:/, message: 'must not contain filter or sort tags. (like score:>30) Use the Minimum Score setting instead.' }
  validates :min_score, comparison: { greater_than: -1, less_than: 301 }
  validates :custom_url, format: { with: /\A[a-zA-Z\-_]*\z/, message: 'must be a valid in a url, with no spaces or special characters' }
  validates_uniqueness_of :custom_url, allow_nil: true, unless: ->(l) { l.custom_url.blank? }
  has_many :reports, as: :reportable
  has_many :history_events, dependent: :destroy

  visitable :ahoy_visit

  pg_search_scope :search_positive, against: %i[terms theme custom_url response_text post_description], associated_against: {
    user: %i[username details]
  }, using: { tsearch: { dictionary: 'english', prefix: true, any_word: true } }

  pg_search_scope :search_negative, against: :blacklist, using: { tsearch: { dictionary: 'english', any_word: true } }

  scope :is_online, -> {
    where('last_ping > ?', Time.now - 1.minute)
      .or(where('live_client_started_at > ?', Time.now - 7.days))
      .or(where("last_ping_user_agent LIKE '%widgetExtension%'").where('last_ping > ?', Time.now - 20.minutes))
  }

  scope :with_ability_to, ->(ability_name) { joins(:abilities).where('link_abilities.ability': ability_name) }

  scope :is_public, -> {
    (
      where(friends_only: false)
    ).and(
      where('expires > ?', Time.now).or(where(never_expires: true))
    )
  }

  def is_online?
    is_ios = last_ping_user_agent&.match(/widgetExtension/) || false

    last_ping_online = last_ping > Time.now - 20.minutes if is_ios && last_ping_user_agent && last_ping
    last_ping_online = last_ping > Time.now - 1.minute if !is_ios && last_ping_user_agent && last_ping
    live_client_online = live_client_started_at && (live_client_started_at > Time.now - 7.days)
    last_ping_online || live_client_online
  end

  # @param ["can_show_videos"] ability
  def check_ability(ability)
    result = abilities.any? { |edge| edge.ability == ability }

    return result && user.master.present? if ability == 'is_master_only'
    result
  end

  def toggle_ability(ability_name)
    set_ability(ability_name, !check_ability(ability_name))
  end

  def set_ability(ability_name, value)
    able_to = check_ability ability_name
    if able_to && !value
      abilities.delete_by ability: ability_name
    elsif !able_to && value
      abilities.create ability: ability_name
    end
  end

  # @return [User | nil]
  def get_set_by_user
    return User.find(self.set_by_id) if self.set_by_id
    nil unless self.set_by_id
  end

  def seconds_since_last_set
    past_links.last.present? ? Time.now - past_links.last.created_at : 99999
  end

  after_update_commit do
    if blacklist_previously_changed? || terms_previously_changed? || theme_previously_changed? || response_text_previously_changed? || last_ping_user_agent_previously_changed? || live_client_started_at_previously_changed? || expires_previously_changed? || never_expires_previously_changed? || friends_only_previously_changed? || post_url_previously_changed?
      begin
        broadcast_update
        broadcast_update_to "link_preview_#{id}_image", target: "preview_image", partial: 'links/embed_image', locals: { link: self }
        broadcast_update_to "link_preview_#{id}_text", target: "preview_text", partial: 'links/embed_text', locals: { link: self }
        link = {}
        link[:success] = true
        link[:id] = self.id
        link[:expires] = self.expires
        link[:terms] = self.terms
        link[:blacklist] = self.blacklist
        link[:post_url] = self.post_url
        link[:post_thumbnail_url] = self.post_thumbnail_url
        link[:post_description] = self.post_description
        link[:response_type] = self.response_type
        link[:response_text] = self.response_text
        link[:set_by] = get_set_by_user&.username
        link[:updated_at] = self.updated_at
      rescue
        link = {
          success: false,
          why: 'Fetching link failed.'
        }
      end
      ActionCable.server.broadcast(
        "Link::#{id}",
        link
      )
    end
  end

  def snapshot
    <<~OUT.strip
      ##{id}
      Creator: #{user.username}
      #{terms}

      Theme: #{theme}
      Blacklist: #{blacklist}
      Post URL: #{post_url}
      Set By: #{set_by&.username || 'anon or no one'}
      Response Text: #{response_text}
    OUT
  end

  def to_s
    "Link ##{id}"
  end
end
