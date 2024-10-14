class CreateForms < ActiveRecord::Migration[7.2]
  def change
    create_table :surveys do |t|
      t.references :user, null: false, foreign_key: true
      t.text :title, null: false
      t.text :description, default: '', null: false
      t.boolean :public, default: false, null: false

      t.timestamps
    end
  end
end
