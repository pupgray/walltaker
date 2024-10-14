class Survey < ApplicationRecord
  belongs_to :user
  has_many :form_elements, -> { order(sort_order: :asc) }, dependent: :destroy
  has_many :responses, class_name: 'SurveyResponse', dependent: :destroy

  validates :title, presence: true, length: { maximum: 50 }
end
