class CumBeggingController < ApplicationController
  def index
    @current_cumcount = Nuttracker::Orgasm.where('created_at > ?', '2024-04-01'.to_datetime).count
  end
end
