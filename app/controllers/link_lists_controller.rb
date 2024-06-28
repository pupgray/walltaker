class LinkListsController < ApplicationController
  def index
    @pagy, @kinks = pagy(Kink.joins(:kink_havers, :links).where(links: Link.is_public).having('count(links) > 0').group(:id).order('count(kink_havers) desc'), items: 5)
  end

  def show
    @kink = Kink.find(params[:id])
    @pagy, @links = pagy(@kink.links.is_public.order(updated_at: :desc), items: 25)
  end
end
