class AddAdvancedToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :advanced, :boolean, null: false, default: false
  end
end
