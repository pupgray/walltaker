class NewsRoomController < ApplicationController
  layout 'full_width'

  def index
    @past_link = PastLink.order(id: :desc).first
    @news_entry = NewsEntry.from_past_link(@past_link)
  end
end
