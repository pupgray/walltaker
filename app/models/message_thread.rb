class MessageThread < ApplicationRecord
  include ActionView::RecordIdentifier
  has_many :participants, class_name: "MessageThreadParticipant"
  has_many :users, through: :participants
  has_many :messages

  # @param [Message] message
  def on_new_message(message)
    participants.where(notify: true).includes(:user).each do |participant|
      next if participant.user == message.from_user
      Notification.create user: participant.user, notification_type: :new_message, text: "#{message.from_user.username}: #{message.content.truncate 24}", link: Rails.application.routes.url_helpers.message_thread_path(self)
    end
    broadcast_prepend target: self, partial: 'message_thread/single_message', locals: { message: }
  end

  def self.find_common_thread(*users)
    self.joins(:participants, :users).where(users: users).group('message_threads.id').having('count(distinct users.id) = ?', users.length).first
  end
end
