class HistoryEvent < ApplicationRecord
  belongs_to :user
  belongs_to :surrender_controller, class_name: 'User', optional: true
  belongs_to :link
  belongs_to :ahoy_visit, class_name: 'Ahoy::Visit', optional: true

  enum :did_what, %i[looked_at set_wallpaper commented_on]

  validates :created_at, comparison: { greater_than: 2.months.ago }, on: :update

  def self.record(user, did_what, link, surrender_controller = nil, ahoy_visit = nil)
    HistoryEvent.create(user:, did_what:, link:, surrender_controller:, ahoy_visit:)
  end
end
