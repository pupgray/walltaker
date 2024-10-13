class AddCutieAndSupporterToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :is_cutie, :boolean, default: false
    add_column :users, :is_supporter, :boolean, default: false
  end
end
