class CreateSurveyResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :survey_responses do |t|
      t.references :survey, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
