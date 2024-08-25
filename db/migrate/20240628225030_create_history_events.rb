class CreateHistoryEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :history_events do |t|
      t.integer :did_what, null: false, default: 0
      t.references :ahoy_visit, foreign_key: true, null: true
      t.references :user, null: false, foreign_key: true
      t.references :surrender_controller, null: true, foreign_key: { to_table: :users }
      t.references :link, null: false, foreign_key: true

      t.timestamps
    end
  end
end
