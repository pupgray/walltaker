class WallsController < ApplicationController
  before_action :authorize, except: %i[index show]
  before_action :set_wall, only: %i[show edit update destroy]

  def show
    redirect_to new_wall_path unless @wall
    render layout: 'thin'
  end

  def new
    return redirect_to edit_wall_path if current_user.wall
    @wall = Wall.new
    @wall.user = current_user
    @wall.save
    redirect_to edit_wall_path
  end

  def create
    @wall = Wall.new(wall_params)
    @wall.user = current_user

    unless @wall.save
      broadcast_notice 'Something went wrong, copy and paste your code to somewhere safe before trying again!'
    end

    render :show
  end

  def edit
    render layout: 'full_width'
  end

  def update
    @wall.content = wall_params[:content]

    unless @wall.save
      broadcast_notice 'Something went wrong, copy and paste your code to somewhere safe before trying again!'
    end

    render :show
  end

  def destroy

  end

  private

  def set_wall
    @wall = current_user.wall
  end

  def wall_params
    params.require(:wall).permit(:content)
  end
end
