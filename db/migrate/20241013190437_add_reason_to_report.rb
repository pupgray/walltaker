class AddReasonToReport < ActiveRecord::Migration[7.2]
  def change
    add_column :reports, :reason, :text, default: ''
  end
end
