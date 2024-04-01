class DashboardController < ApplicationController
  after_action :track_visit, only: %i[index]

  def index
    unless current_user.nil?
      @recent_posts = PastLink.order(id: :desc).take 7
      wallpapers_changed_today = Rails.cache.fetch("v1/totalchangedtoday", expires_in: 2.minutes) { PastLink.where(created_at: Time.now.beginning_of_day..Time.now.end_of_day) }
      @total_wallpapers_changed_today_by_user = Rails.cache.fetch("v1/changedtodaychart", expires_in: 5.minutes) do
        wallpapers_changed_today
          .joins(:user)
          .select('COUNT(DISTINCT past_links.id) as total, users.username')
          .group('users.username')
          .order(total: :desc)
          .limit(20)
      end
      @total_wallpapers_changed_all = Rails.cache.fetch("v1/totallinkchanges", expires_in: 45.minutes) { PastLink.count }
      @your_total_wallpapers_changed_all = PastLink.where(user_id: current_user.id).count if current_user
      @total_wallpapers_changed_grouped_by_day = PastLink.group_by_minute(:created_at, range: (2.5).days.ago..Time.now).count.inject ({}) do |acc, minute|
        record_time = minute[0]
        record_count = minute[1]

        hour = acc[record_time.beginning_of_hour] || [0, 0, 999, 0]
        last_hour = acc[record_time.beginning_of_hour - 1.hour] || [hour[0], hour[0], 999, 0]

        hour[1] = last_hour[0]

        sum_of_averages = ((hour[0] * record_time.min * 60) + record_count)
        hour[0] = sum_of_averages / ((record_time.min.to_f * 60) + 1)

        hour[2] = [hour[2], record_count].min
        hour[3] = [hour[3], record_count].max
        { **acc, record_time.beginning_of_hour => hour }
      end
      @newest_user = User.last
      @online_links_count = Rails.cache.fetch("v1/onlinelinkcount", expires_in: 5.minutes) do
        Link.all
            .where(friends_only: false)
            .is_online
            .and(
              Link.all.where('expires > ?', Time.now).or(Link.all.where(never_expires: true))
            ).count
      end

      @users_viewing_links = User.where.not(viewing_link_id: nil)
    end
  end
end
