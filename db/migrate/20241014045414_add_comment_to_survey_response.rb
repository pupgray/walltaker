class AddCommentToSurveyResponse < ActiveRecord::Migration[7.2]
  def change
    add_column :survey_responses, :comment, :text, default: ''
  end
end
