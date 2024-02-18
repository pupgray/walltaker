class PastLinkResponse < ApplicationRecord
  enum response_type: %i[horny came disgust]
  belongs_to :past_link

  after_commit do
    if is_on_current_post
      set_as_main_response
    end
  end
  def is_on_current_post
    true
  end
  def set_as_main_response
    broadcast_replace_to "link_response_#{past_link.link.id}", target: "link_response_#{past_link.link.id}", partial: 'links/response', locals: { reaction: self, link: self.past_link.link }
  end
end
