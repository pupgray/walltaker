class CreateWalls < ActiveRecord::Migration[7.1]
  def change
    create_table :walls do |t|
      t.references :user
      t.string :title, default: 'My Wall'
      t.string :content, default: ''
      t.integer :hits, default: 0

      t.timestamps
    end
  end
end
