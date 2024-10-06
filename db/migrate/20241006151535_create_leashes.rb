class CreateLeashes < ActiveRecord::Migration[7.2]
  def change
    create_table :leashes do |t|
      t.references :friendship, null: false, foreign_key: true
      t.references :master, null: false, foreign_key: { to_table: :users }
      t.references :pet, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
