class AddPublicToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :public, :boolean, null: false, default: false
  end
end
