class MessageThreadParticipantController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :authorize

  def update
    message_thread = MessageThread.find(params[:message_thread_id])
    participant = MessageThreadParticipant.find(params[:id])

    if participant.user == current_user
      result = participant.update(participant_params)

      if result
        render turbo_stream: turbo_stream.update(dom_id(message_thread) + '-controls', partial: 'message_thread/controls', locals: { message_thread: message_thread })
      else
        render turbo_stream: turbo_stream.update(dom_id(message_thread) + '-controls', partial: 'message_thread/controls', locals: { message_thread: message_thread }), alert: 'Something went wrong'
      end
    else
      render turbo_stream: turbo_stream.update(dom_id(message_thread) + '-controls', partial: 'message_thread/controls', locals: { message_thread: message_thread }), alert: 'Something went wrong'
    end
  end

  private

  def participant_params
    params.require(:message_thread_participant).permit(:notify)
  end
end
