class ScoopPopJob < ApplicationJob
  queue_as :default

  def perform(*args)
    next_scoop = Scoop.where(was_shown: false).order(created_at: :asc).first
    mutex = Rails.cache.fetch('v1/newsroom_mutex')
    if next_scoop && !mutex.present?
      news_entry = NewsEntry.from_scoop(next_scoop)
      PushNewsJob.perform_later(news_entry.to_json)
      next_scoop.update(was_shown: true)
    end
  end
end
