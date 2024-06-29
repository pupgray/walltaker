class Ahoy::Visit < ApplicationRecord
  self.table_name = "ahoy_visits"

  has_many :events, class_name: "Ahoy::Event"
  has_many :history_events, dependent: :destroy
  has_one :banned_ip, foreign_key: :ip_address, primary_key: :ip, dependent: :destroy
  belongs_to :user, optional: true
end
