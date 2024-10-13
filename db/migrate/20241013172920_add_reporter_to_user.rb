class AddReporterToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :is_reporter, :boolean, default: false
  end
end
