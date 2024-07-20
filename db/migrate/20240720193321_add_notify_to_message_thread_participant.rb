class AddNotifyToMessageThreadParticipant < ActiveRecord::Migration[7.1]
  def change
    add_column :message_thread_participants, :notify, :boolean, null: false, default: true
  end
end
