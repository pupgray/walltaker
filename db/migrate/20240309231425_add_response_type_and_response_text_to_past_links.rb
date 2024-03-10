class AddResponseTypeAndResponseTextToPastLinks < ActiveRecord::Migration[7.1]
  def change
    add_column :past_links, :response_text, :string
    add_column :past_links, :response_type, :integer
  end
end
