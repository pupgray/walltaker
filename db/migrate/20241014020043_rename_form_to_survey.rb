class RenameFormToSurvey < ActiveRecord::Migration[7.2]
  def change
    rename_table :forms, :surveys
    rename_column :form_elements, :survey_id, :survey_id
  end
end
