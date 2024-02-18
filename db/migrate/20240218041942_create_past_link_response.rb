class CreatePastLinkResponse < ActiveRecord::Migration[7.1]
  def change
    create_table :past_link_responses do |t|
      t.string :response_text
      t.integer :response_type
      t.references :past_link, index: true, null: false

      t.timestamps
    end
  end
end
