class AddCurrentProfileToUser < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :profile, null: true, foreign_key: true
  end
end
