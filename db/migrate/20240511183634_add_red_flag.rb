class AddRedFlag < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :flagged, :boolean, default: false
  end
end
