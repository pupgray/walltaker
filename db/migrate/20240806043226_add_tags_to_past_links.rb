class AddTagsToPastLinks < ActiveRecord::Migration[7.1]
  def change
    add_column :past_links, :tags, :text, null: false, default: ''
  end
end
