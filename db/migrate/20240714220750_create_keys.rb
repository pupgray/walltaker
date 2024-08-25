class CreateKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :keys do |t|
      t.string :purpose, null: false
      t.text :public, null: false
      t.text :private, null: false

      t.timestamps
    end

    add_index :keys, :purpose, unique: true
  end
end
