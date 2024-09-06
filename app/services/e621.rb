class E621
  def get_tag_results(tag_string, after, before, link, limit = 15)
    if link.nil?
      append_to_tags = ''
      padded_tag_string = tag_string
      link_can_show_videos = true
    else
      link_can_show_videos = link.check_ability 'can_show_videos'

      sanitized_blacklist = make_blacklist(link)
      blacklist_tags = sanitized_blacklist.split(' ')
      deduped_tag_string = tag_string.split(' ').filter { |tag| blacklist_tags.none? tag }.uniq.join(' ')

      append_to_tags = make_tag_suffix(link, sanitized_blacklist, deduped_tag_string)

      padded_tag_string = deduped_tag_string
    end

    unless append_to_tags.nil? || append_to_tags.empty?
      padded_tag_string += " #{append_to_tags.to_s}"
    end

    tags = CGI.escape padded_tag_string

    key = "v1/tagresults/#{tags}/#{after}/#{before}/#{limit}/#{link_can_show_videos}"
    cache_hit = Rails.cache.read(key)

    unless cache_hit.nil?
      cache_hit
    else
      url = "https://e621.net/posts.json?tags=#{tags}"
      after_id = after.gsub(/\D/, '') if after
      url = "#{url}&page=b#{after_id}" if after_id
      before_id = before.gsub(/\D/, '') if before
      url = "#{url}&page=a#{before_id}" if before_id
      url = "#{url}&limit=#{limit}"
      response = Excon.get(url, headers: { 'User-Agent': 'walltaker.joi.how (by ailurus on e621)' })
      if response.status != 200
        track :error, :e621_posts_api_fail, response: response
        return nil
      end

      results = JSON.parse(response.body)['posts']
      if results.present? && results.class == Array
        if /order:random/i =~ padded_tag_string
          Rails.cache.write(key, results, expires_in: 1.minute)
        else
          Rails.cache.write(key, results, expires_in: 45.minutes)
        end

        unless link_can_show_videos
          results.filter do |post|
            %w[png jpg bmp webp].include? post['file']['ext']
          end
        else
          results
        end
      else
        []
      end
    end
  end

  def get_possible_post_count(link)
    (get_tag_results '', nil, nil, link, 150)&.count
  end

  def make_tag_suffix(link, sanitized_blacklist, query)
    kink_in_query = false
    if link.check_ability 'is_kink_aligned'
      kinks = link.user.kinks.pluck(:name)

      kink_in_query = query.split(' ').any? { |tag| kinks.any? tag }
    end
    append_to_tags = '-flash '
    append_to_tags += link.theme if (link.theme)
    append_to_tags += ' ' + ((sanitized_blacklist.split.map { |tag| "-#{tag}" }).join ' ') unless (sanitized_blacklist.empty?)
    append_to_tags += ' score:>' + link.min_score.to_s if link.min_score.present? && link.min_score != 0
    append_to_tags += ' -animated' unless link.check_ability 'can_show_videos'
    append_to_tags += ' ' + link.user.kinks.pluck(:name).map { |name| "~#{name}" }.join(' ') if link.check_ability('is_kink_aligned') && !kink_in_query
    append_to_tags
  end

  def make_blacklist(link)
    link&.blacklist&.downcase&.gsub(/[^a-z_\(\)\d\: ]/, '') || ''
  end

  def get_search_base(link)
    sanitized_blacklist = make_blacklist(link)
    make_tag_suffix(link, sanitized_blacklist, '')
  end

  def get_post(id, link)
    result = get_tag_results "id:#{id}", nil, nil, link, 1

    result&.count&.positive? ? result[0] : nil
  end
end
