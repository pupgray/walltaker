class PushNewsJob < ApplicationJob
  queue_as :news

  def perform(news_entry_json)
    news_entry = NewsEntry.new.from_json(news_entry_json)
    if news_entry.image_url.present?
      Turbo::StreamsChannel.broadcast_update_to :news_backdrop, target: :news_backdrop, partial: 'news_room/backdrop', locals: { news_entry: }
    end
    Turbo::StreamsChannel.broadcast_update_to :desk, target: :desk, partial: 'news_room/desk', locals: { news_entry: }

    if news_entry.lizard_image_url == 'mascot/news/TaylorDeskOpen.png'
      news_entry.lizard_image_url = 'mascot/news/TaylorDeskClosed.png'
      PushNewsJob.set(wait: 3.seconds).perform_later(news_entry.to_json)
    end
  end
end
