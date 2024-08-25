class CreateScoops < ActiveRecord::Migration[7.2]
  def change
    create_table :scoops do |t|
      t.references :user, null: false, foreign_key: true
      t.text :details
      t.references :link, null: true, foreign_key: true

      t.timestamps
    end
  end
end
