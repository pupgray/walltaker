class SurveyResponse < ApplicationRecord
  belongs_to :survey
  belongs_to :user, required: false

  has_many :answers, class_name: 'SurveyResponseAnswer', dependent: :destroy
end
