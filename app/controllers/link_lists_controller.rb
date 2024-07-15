class LinkListsController < ApplicationController
  def index
    return redirect_to link_lists_path if current_user.nil? && params[:filter] == 'mine'

    query = Kink.joins(:kink_havers, :links).where(links: Link.is_public).having('count(links) > 0').group(:id).order('count(kink_havers) desc') if params[:filter].nil?
    query = Kink.joins(:kink_havers, :links).where(links: Link.is_public, id: current_user.kinks.pluck(:id)).having('count(links) > 0').group(:id).order('count(kink_havers) desc') if params[:filter] == 'mine'
    @pagy, @kinks = pagy(query, items: 5)
  end

  def show
    @kink = Kink.find(params[:id])
    @pagy, @links = pagy(@kink.links.is_public.order(updated_at: :desc), items: 25)
  end
end
