class SurrendersController < ApplicationController
  before_action :authorize, except: %i[show destroy]
  before_action :authorize_for_surrendered_accounts, only: %i[show destroy]
  before_action :set_friendship_options, only: %i[new edit]
  before_action :set_surrender, only: %i[show edit destroy assume]
  before_action :protect_own_surrender, only: %i[show destroy]

  def index
    @current_surrender = current_user.current_surrender
  end

  def show
  end

  def create
    friendship = Friendship.involving(current_user).is_confirmed.find(surrender_params[:friendship])

    if friendship.present?
      # Calculate expiration time based on selected duration
      duration_hours = surrender_params[:duration].to_i
      expires_at = Time.now + duration_hours.hours

      surrender = current_user.create_current_surrender(
        expires_at: expires_at,
        friendship: friendship,
        accepted_consequences: surrender_params[:accepted_consequences],
        pending: surrender_params[:pending]
      )

      if surrender.save
        Notification.create(
          user: surrender.controller,
          notification_type: :surrender_event,
          link: friendships_path,
          text: "#{surrender.user.username} has allowed you to log into their account. You can do so in the friends menu."
        )
        redirect_to surrender_path(surrender), notice: 'Surrender was successfully created. Now just wait...'
      else
        redirect_to new_surrender_path, alert: surrender.errors.full_messages.first
      end
    else
      redirect_to new_surrender_path, alert: 'Friendship does not exist.'
    end
  end

  def new
    @surrender = Surrender.new
  end

  def destroy
    if @surrender.destroy
      redirect_to surrenders_path, notice: 'Surrender was successfully destroyed.'
    else
      redirect_to surrender_path(@surrender), alert: 'Surrender could not be destroyed.'
    end
  end

  def assume
    # It's reallllllly important we don't fuck up here. Each guard on its own line, please.

    return redirect_to root_path, alert: 'Not allowed.' if @surrender.nil?
    return redirect_to root_path, alert: 'Not allowed.' if @surrender.invalid?
    return redirect_to root_path, alert: 'Not allowed.' if @surrender.controller != current_user
    return redirect_to surrender_path(@surrender), alert: '... what? How does that even make sense? You chose to surrender your account, then assume your own account?' if @surrender.user == current_user

    @surrender.logged_in = true
    @surrender.pending = false if @surrender.pending?

    @surrender.save

    log_in_as(@surrender.user, @surrender)
  end

  private

  def set_friendship_options
    friendships = Friendship.involving(current_user).is_confirmed
    @friendship_options = friendships.map { |f| [f.other_user(current_user).username, f.id] }
  end

  def set_surrender
    @surrender = Surrender.find(params[:id])
  end

  def surrender_params
    params.require(:surrender).permit(:friendship, :pending, :accepted_consequences, :duration)
  end

  def protect_own_surrender
    redirect_to surrenders_path, alert: 'You cannot configure this surrender.' if @surrender.user != current_user
  end
end
