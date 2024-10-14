class FormElement < ApplicationRecord
  belongs_to :survey
  has_many :survey_response_answers, dependent: :destroy
  enum :kind, [:text, :yapping, :yes_or_no, :score, :acceptance]

  validates :label, presence: true, length: { maximum: 120 }
  validates :sort_order, uniqueness: { scope: :survey }
end
