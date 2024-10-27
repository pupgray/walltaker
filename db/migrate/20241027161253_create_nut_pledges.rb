class CreateNutPledges < ActiveRecord::Migration[7.2]
  def change
    create_table :nut_pledges do |t|
      t.references :user, null: false, foreign_key: true
      t.references :past_link, null: true, foreign_key: true
      t.datetime :failed_on, null: true

      t.timestamps
    end
  end
end
