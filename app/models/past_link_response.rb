class PastLinkResponse < ApplicationRecord
  enum response_type: %i[horny came disgust]
  belongs_to :past_link

  after_commit do
    # This check doesn't improve the number of database queries, but it does save unnecessary updates from being pushed.
    update_main_response if is_on_current_post
  end

  after_destroy do
    # This can potentially send unnecessary updates, but fixing it is more trouble than it's worth
    update_main_response
  end

  def is_on_current_post
    past_link.id == past_link.link.current_post.id
  end

  def update_main_response
    broadcast_replace_to "link_response_#{past_link.link.id}", target: "link_response_#{past_link.link.id}", partial: 'links/response', locals: { reaction: self.past_link.link.current_reaction, link: self.past_link.link }
  end
end
