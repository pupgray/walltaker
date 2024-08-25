class MessageThreadParticipant < ApplicationRecord
  belongs_to :user, inverse_of: :message_thread_participants
  belongs_to :message_thread, inverse_of: :participants
end
