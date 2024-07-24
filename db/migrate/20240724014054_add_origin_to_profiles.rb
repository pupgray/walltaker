class AddOriginToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_reference :profiles, :origin, null: true, foreign_key: { to_table: :profiles }
  end
end
