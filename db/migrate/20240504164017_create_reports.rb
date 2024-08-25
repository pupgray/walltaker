class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :reportable, polymorphic: true
      t.boolean :is_closed, default: false
      t.string :snapshot

      t.timestamps
    end
  end
end
