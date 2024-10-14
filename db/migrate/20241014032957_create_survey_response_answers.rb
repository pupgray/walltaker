class CreateSurveyResponseAnswers < ActiveRecord::Migration[7.2]
  def change
    create_table :survey_response_answers do |t|
      t.references :form_element, null: false, foreign_key: true
      t.references :survey_response, null: false, foreign_key: true
      t.text :value

      t.timestamps
    end
  end
end
