class CreateFormElements < ActiveRecord::Migration[7.2]
  def change
    create_table :form_elements do |t|
      t.string :label, null: false
      t.integer :kind, null: false
      t.references :survey, null: false, foreign_key: true
      t.integer :sort_order, null: false
      t.boolean :required, default: false, null: false

      t.index [:form_id, :sort_order], unique: true, order: { order: :asc }

      t.timestamps
    end
  end
end
