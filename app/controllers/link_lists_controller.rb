class LinkListsController < ApplicationController
  def index
    return redirect_to link_lists_path if current_user.nil? && params[:filter] == 'mine'

    query = Kink.joins(:kink_havers, :links).where(links: Link.is_public).having('count(links) > 0') if params[:filter].nil?
    query = Kink.joins(:kink_havers, :links).where(links: Link.is_public, id: current_user.kinks.pluck(:id)).having('count(links) > 0').group(:id).order('count(kink_havers) desc') if params[:filter] == 'mine'

    query = query.search_name(params[:q]).group(:rank, :id).order('count(kink_havers) desc') if params[:q].present?
    query = query.group(:id).order('count(kink_havers) desc') unless params[:q].present?

    @pagy, @kinks = pagy_arel(query, items: 5)
  end

  def show
    @kink = Kink.find(params[:id])
    @pagy, @links = pagy(@kink.links.is_public.order(updated_at: :desc), items: 25)
  end

  private

  def filter_params
    params.permit(:filter, :q)
  end

  helper_method :filter_params
end
