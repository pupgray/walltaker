class PushNewsJob < ApplicationJob
  def perform(news_entry_json, transitioning: false, done: false)
    news_entry = NewsEntry.new.from_json(news_entry_json)

    Rails.cache.write('v1/newsroom_mutex', { news_entry: news_entry.to_json, transitioning:, done: }, expires_in: 50.seconds)

    if transitioning == :away
      follow_up = news_entry.clone
      follow_up.transition_message = nil

      transition = NewsEntry.new
      transition.message = "Let's find out more"
      transition.lizard_image_url = 'mascot/news/TaylorDeskTransition.png'

      Turbo::StreamsChannel.broadcast_update_to :desk, target: :desk, partial: 'news_room/desk', locals: { news_entry: transition }

      PushNewsJob.set(wait: 3.seconds).perform_later(follow_up.to_json)
      return
    end

    if transitioning == :to_desk
      follow_up = news_entry.clone
      follow_up.transition_message = nil

      transition = NewsEntry.new
      transition.message = "... And we're back! If anything else happens I'll keep you posted!"
      transition.lizard_image_url = 'mascot/news/TaylorDeskTransition.png'

      Turbo::StreamsChannel.broadcast_update_to :desk, target: :desk, partial: 'news_room/desk', locals: { news_entry: follow_up }
      Turbo::StreamsChannel.broadcast_remove_to :chyron, target: :chyron

      PushNewsJob.set(wait: 5.seconds).perform_later(transition.to_json, done: true)
      return
    end

    if news_entry.transition_message.present?
      breaking_news = news_entry.clone
      breaking_news.message = news_entry.transition_message
      news_entry.transition_message = nil
      breaking_news.lizard_image_url = 'mascot/news/TaylorDeskBreakingNews.png'
      Rails.cache.write('v1/newsroom_mutex', { news_entry: news_entry.to_json, transitioning:, done: }, expires_in: 50.seconds)

      Turbo::StreamsChannel.broadcast_update_to :desk, target: :desk, partial: 'news_room/desk', locals: { news_entry: breaking_news }
      PushNewsJob.set(wait: 4.seconds).perform_later(news_entry.to_json, transitioning: :away)
    else
      Turbo::StreamsChannel.broadcast_update_to :desk, target: :desk, partial: 'news_room/desk', locals: { news_entry: }
      if news_entry.type == 'scoop'
        follow_up = news_entry.clone
        follow_up.lizard_image_url = follow_up.lizard_image_url.gsub('InterviewOpen', 'InterviewClosed')
        follow_up.message = 'Wow! Thanks!'
        follow_up.type = 'post'

        word_count = news_entry.message.scan(/\w+/).size
        time_to_wait = (word_count * 2) + 6

        Rails.cache.write('v1/newsroom_mutex', { news_entry: news_entry.to_json, transitioning:, done: }, expires_in: 50.seconds)

        PushNewsJob.set(wait: time_to_wait.seconds).perform_later(follow_up.to_json, transitioning: :to_desk)
      else
        if news_entry.image_url.present?
          Turbo::StreamsChannel.broadcast_update_to :news_backdrop, target: :news_backdrop, partial: 'news_room/backdrop', locals: { news_entry: }
        end

        if done
          resting = NewsEntry.new
          resting.lizard_image_url = 'mascot/news/TaylorDeskClosed.png'
          PushNewsJob.set(wait: 5.seconds).perform_later(resting.to_json)
        end

        if news_entry.lizard_image_url == 'mascot/news/TaylorDeskClosed.png'
          Rails.cache.delete('v1/newsroom_mutex')
        end

        if news_entry.lizard_image_url == 'mascot/news/TaylorDeskOpen.png'
          news_entry.lizard_image_url = 'mascot/news/TaylorDeskClosed.png'
          PushNewsJob.set(wait: 3.seconds).perform_later(news_entry.to_json)
        end
      end
    end
  end
end
