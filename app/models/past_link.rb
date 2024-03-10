class PastLink < ApplicationRecord
  belongs_to :link
  belongs_to :user
  belongs_to :set_by, foreign_key: :set_by_id, class_name: 'User', optional: true
  visitable :ahoy_visit
  enum response_type: %i[horny came disgust]

  def self.log_link(link) # post_url, post_thumbnail_url, set_by_id
    new({
          link:,
          user: link.user,
          post_url: link.post_url,
          post_thumbnail_url: link.post_thumbnail_url,
          set_by_id: link.set_by_id
        })
  end


  def set_reaction (response_type, response_text)
    # Make notification for setter
    notification_text = "#{link.user.username} loved your post!" if response_type == 'horny'
    notification_text = "#{link.user.username} did not like your post." if response_type == 'disgust'
    notification_text = "#{link.user.username} came to your post!" if response_type == 'came'
    notification_text = "#{notification_text} \"#{response_text}\"" unless response_type.nil?
    Notification.create user_id: set_by_id, notification_type: :post_response, text: notification_text, link: "/links/#{link.id}"

    # Log reaction in chat sidebar
    setter_name = set_by&.username || "anon"
    comment_text = "> loved #{setter_name}'s wallpaper! #{ post_url }" if response_type == 'horny'
    comment_text = "> hated it. #{ post_url }" if response_type == 'disgust'
    comment_text = "> came to #{setter_name}'s wallpaper! #{ post_url }" if response_type == 'came'
    Comment.create user_id: link.user.id, link_id: link.id, content: comment_text
    Comment.create user_id: link.user.id, link_id: link.id, content: response_text unless response_type.nil?

    # If a came reaction, log an orgasm
    Nuttracker::Orgasm.create rating: 3, is_ruined: false, user: link.user, caused_by: set_by if response_type == 'came'

    # If a disgust reaction, revert to old wallpaper
    is_current_post = link.current_past_link == self
    if response_type == 'disgust'
      previous_past_post = link.past_links.where.not(id: id).last
      if is_current_post
        link.post_url = previous_past_post ? previous_past_post.post_url : nil
        link.post_thumbnail_url = previous_past_post ? previous_past_post.post_thumbnail_url : nil
        link.set_by = previous_past_post&.set_by
      end
      self.destroy
      link.save! # failure should only happen here if we've made a mistake, so throw rather than return false
      return self.destroyed?
    end
    self.response_text = response_text
    self.response_type = response_type
    return self.save
  end

  after_commit do
    if response_text_previously_changed? || response_type_previously_changed?
      broadcast_replace_to "link_response_#{link_id}", target: "link_response_#{link_id}", partial: 'links/response', locals: { link: self.link } if self.link.current_past_link == self
    end
    broadcast_replace_to "link_details_#{link_id}", target: "link_details_#{link_id}", partial: 'links/details', locals: { link: self.link }
    broadcast_replace_to "dashboard_recent_posts", target: "recent_posts", partial: "dashboard/recent_posts", locals: {
      recent_posts: PastLink.order(id: :desc).take(6)
    }
  end
end
