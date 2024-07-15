class HistoryEventsController < ApplicationController
  before_action :authorize

  def index
    @events = HistoryEvent.where(user: current_user).order(id: :desc).limit(170).group_by(&:ahoy_visit).sort_by { |a| a[0].started_at }.reverse!
  end
end
