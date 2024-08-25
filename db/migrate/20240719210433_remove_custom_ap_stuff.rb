class RemoveCustomApStuff < ActiveRecord::Migration[7.1]
  def up
    drop_table :keys
    drop_table :ap_followers
  end
end
