class PastLink < ApplicationRecord
  belongs_to :link
  belongs_to :user
  belongs_to :set_by, foreign_key: :set_by_id, class_name: 'User', optional: true
  visitable :ahoy_visit

  def self.log_link(link, tag_string)
    new({
          link:,
          user: link.user,
          post_url: link.post_url,
          post_thumbnail_url: link.post_thumbnail_url,
          set_by_id: link.set_by_id,
          tags: tag_string
        })
  end

  after_commit do
    broadcast_replace_to "link_details_#{link_id}", target: "link_details_#{link_id}", partial: 'links/details', locals: { link: self.link }
    broadcast_replace_to "dashboard_recent_posts", target: "recent_posts", partial: "dashboard/recent_posts", locals: {
      recent_posts: PastLink.order(id: :desc).take(6)
    }

    if post_url.ends_with?(".png", ".jpg", ".jpeg", ".gif", ".bmp")
      waiting = Rails.cache.fetch('v1/newsroom_mutex').present?

      unless waiting
        Rails.cache.fetch('v1/pushnewsjob', expires_in: (7..9).to_a.sample.seconds) do
          PushNewsJob.perform_later(NewsEntry.from_past_link(self).to_json)
        end
      end
    end
  end
end
