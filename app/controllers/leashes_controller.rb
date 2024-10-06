class LeashesController < ApplicationController
  before_action :authorize, only: %i[ show new edit create update destroy ]
  before_action :set_leash, only: %i[ show edit update destroy ]

  # GET /leashes or /leashes.json
  def index
    @user = User.find_by_username(params[:user_id])
    @master = @user.master
    @held_leashes = @user.held_leashes.joins(:pet)
  end

  # GET /leashes/1 or /leashes/1.json
  def show
  end

  # GET /leashes/new
  def new
    return redirect_to user_leashes_path(current_user.username), alert: "You're already leashed to #{current_user.master}" if current_user.master.present?

    @leash = Leash.new(pet: current_user)
  end

  # GET /leashes/1/edit
  def edit
  end

  # POST /leashes or /leashes.json
  def create
    @leash = Leash.new(leash_params)
    @leash.master = Friendship.find(leash_params[:friendship_id]).other_user(current_user)
    @leash.pet = current_user

    if @leash.save
      Notification.create user: @leash.master, notification_type: :leash, text: "#{@leash.pet.username} has leashed themselves to you.", link: user_leashes_path(@leash.pet.username)
      redirect_to user_leashes_path(@leash.pet.username), notice: "Leash was successfully created."
    else
      redirect_to new_leash_path, alert: @leash.errors.full_messages.to_sentence
    end
  end

  # PATCH/PUT /leashes/1 or /leashes/1.json
  def update
    if @leash.update(leash_params)
      redirect_to leash_url(@leash), notice: "Leash was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /leashes/1 or /leashes/1.json
  def destroy
    return redirect_to leash_path(@leash), alert: "Pets can't unleash themselves." if (@leash.pet == current_user)

    @leash.destroy

    redirect_to user_path(@leash.pet.username), notice: "Leash was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_leash
    @leash = Leash.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def leash_params
    params.require(:leash).permit(:friendship_id)
  end
end
