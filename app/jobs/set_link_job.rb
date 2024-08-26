class SetLinkJob < ApplicationJob
  queue_as :urgent

  def perform(e621_post:, link:, set_by: nil)
    e621_service = E621.new

    link.update(
      {
        post_url: e621_post['file']['url'],
        post_thumbnail_url: e621_post['sample']['url'] || e621_post['preview']['url'],
        post_description: e621_post['description'],
        set_by_id: set_by.nil? ? nil : set_by.id,
        response_type: nil,
        response_text: nil
      }
    )
    link.forks.each do |fork|
      result = e621_service.get_post e621_post['id'], fork
      SetLinkJob.set(wait: 1.second, priority: 10).perform_later(e621_post: result, link: fork, set_by:) if result
    end
    if set_by.present? && (link.user.id != set_by.id)
      set_by.set_count = set_by.set_count.to_i + 1
      set_by.save
    end
    tag_string = "#{e621_post['tags']['general'].join(' ')} #{e621_post['tags']['character'].join(' ')} #{e621_post['tags']['species'].join(' ')} #{e621_post['tags']['lore'].join(' ')} #{e621_post['tags']['copyright'].join(' ')} #{e621_post['tags']['meta'].join(' ')} rating:#{e621_post['rating']}"
    past_link = PastLink.log_link(link, tag_string)
    past_link.save
  end
end
