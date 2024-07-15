class CreateApFollowers < ActiveRecord::Migration[7.1]
  def change
    create_table :ap_followers do |t|
      t.text :url, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
