class AddFlairToLeashes < ActiveRecord::Migration[7.2]
  def change
    add_column :leashes, :flair, :text, null: true
  end
end
