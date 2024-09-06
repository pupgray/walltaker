class BrowsePopulateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    link_ids = Link.all
          .is_public
          .is_online
          .joins(:user)
          .joins(:past_links)
          .where('past_links.created_at = (SELECT MAX(created_at) FROM past_links WHERE past_links.link_id = links.id)')
          .order(Arel.sql(%q{
                    past_links.created_at - make_interval(secs := users.set_count * 6) ASC
                 }))
          .limit(18)
          .pluck(:id)

    Rails.cache.write("v2/browselinks", link_ids, expires_in: 4.minutes)
  end
end
