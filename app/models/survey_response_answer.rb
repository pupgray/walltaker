class SurveyResponseAnswer < ApplicationRecord
  belongs_to :form_element
  belongs_to :survey_response
end
