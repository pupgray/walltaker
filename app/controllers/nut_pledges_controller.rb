class NutPledgesController < ApplicationController
  before_action :authorize, except: [:show]
  before_action :set_user
  before_action :must_be_current_user, except: [:show]

  def show
    @nut_pledge = @user.nut_pledge
  end

  def new
    redirect_to user_path(@user.username) if @user.nut_pledge.present?
    @nut_pledge = NutPledge.new
  end

  def create
    return redirect_to user_path(@user.username) if @user.nut_pledge.present?
    return redirect_to new_user_nut_pledge_path(@user.username), alert: "Username must be signed exactly!" if params[:nut_pledge][:username] != @user.username

    @nut_pledge = current_user.build_nut_pledge
    if @nut_pledge.save
      redirect_to user_path(@user.username)
    else
      redirect_to new_user_nut_pledge_path(@user.username), alert: "Something went wrong."
    end
  end

  def update
    @nut_pledge = @user.nut_pledge

    if @nut_pledge && !@nut_pledge.failed?
      @nut_pledge.failed_on = Time.now
      @nut_pledge.save
    end

    render :show
  end

  private

  def set_user
    @user = User.find_by_username(params[:user_id])
    @is_current_user = current_user && @user.id == current_user.id
  end

  def must_be_current_user
    redirect_to root_path, alert: "Not Authorized" unless @is_current_user
  end
end
