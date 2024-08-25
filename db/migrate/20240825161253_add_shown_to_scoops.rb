class AddShownToScoops < ActiveRecord::Migration[7.2]
  def change
    add_column :scoops, :was_shown, :boolean, default: false
  end
end
