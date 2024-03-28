class TickerController < ApplicationController
  def index
    users = User.order(updated_at: :desc).limit(20).pluck(:username, :set_count).map {|k| [k[0], k[1], user_path(k[0])]}
    kinks = Kink.joins(:users).group(:id).order('count(users.id) desc').limit(20).pluck(:name, 'count(users.id)', :id).map {|k| [k[0], k[1], kink_path(k[2])]}

    @symbols = [*kinks, *users].map {|u| [*u, %i[red green].sample]}.shuffle
  end
end
