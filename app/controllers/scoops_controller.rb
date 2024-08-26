class ScoopsController < ApplicationController
  before_action :authorize, only: %i[index new create edit update destroy]

  def index
    @scoops = current_user.scoops.order(created_at: :desc).limit(40)
  end

  def show
    @scoop = Scoop.find(params[:id])
  end

  def new
    @scoop = Scoop.new
  end

  def create
    @scoop = current_user.scoops.new(scoop_params)

    if @scoop.save
      redirect_to scoops_path
    else
      redirect_to new_scoop_path, alert: @scoop.errors.full_messages.to_sentence
    end
  end

  def edit
    @scoop = Scoop.find(params[:id])

    redirect_to scoops_path unless @scoop.present?
  end

  def update
    @scoop = Scoop.find(params[:id])

    if @scoop.update(scoop_params)
      redirect_to edit_scoop_path(@scoop), notice: 'Updated! When this scoop is passed to the newsroom, it will use your new content.'
    else
      redirect_to edit_scoop_path(@scoop), alert: @scoop.errors.full_messages.to_sentence
    end
  end

  def destroy
    @scoop = Scoop.find(params[:id])

    unless @scoop.was_shown
      if @scoop.destroy
        redirect_to scoops_path, notice: 'Successfully stopped the presses, scoop will not run.'
      else
        redirect_to scoop_path(@scoop), alert: @scoop.errors.full_messages.to_sentence
      end
    else
      redirect_to scoop_path(@scoop), alert: 'Scoop was already shown!'
    end
  end

  private

  def scoop_params
    params.require(:scoop).permit(:details)
  end
end
