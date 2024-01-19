class AddIdUniquenessConstraintToFriendships < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :friendships, 'sender_id <> receiver_id', name: 'not_friending_self'
  end
end
