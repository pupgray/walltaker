class AddPendingToSurrenders < ActiveRecord::Migration[7.1]
  def change
    add_column :surrenders, :pending, :boolean, default: false
  end
end
