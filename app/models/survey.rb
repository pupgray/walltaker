class Survey < ApplicationRecord
  belongs_to :user
  has_many :form_elements, -> { order(sort_order: :asc) }, dependent: :destroy

  validates :title, presence: true, length: { maximum: 50 }
end
