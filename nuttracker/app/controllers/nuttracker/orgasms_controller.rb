module Nuttracker
  class OrgasmsController < ApplicationController
    before_action :set_orgasm, only: %i[ show edit update destroy ]
    before_action :authorize, only: %i[ create new edit update destroy ]
    before_action :protected, only: %i[ edit update destroy ]

    # GET /orgasms
    def index
      @orgasms = Orgasm.all
    end

    # GET /orgasmers/:username
    def index_for_user
      @user = User.find_by(username: params['username']) if params['username']
      @orgasms = Orgasm.all.where(user: @user) if @user.present?
      @orgasms = Orgasm.none unless @user.present?
    end

    # GET /orgasms/1
    def show
    end

    # GET /orgasms/new
    def new
      @orgasm = Orgasm.new
      @pornlizard = current_user.find_pornlizard
      @friends = Friendship.joins(:receiver, :sender).involving(current_user).is_confirmed.map { |f| f.other_user(current_user) }
      @recent_setters = PastLink.joins(:set_by).where(user: current_user).where.not(set_by: nil).select(:set_by_id).group(:set_by_id).limit(10).map { |pl| pl.set_by }
    end

    # GET /orgasms/1/edit
    def edit
    end

    # POST /orgasms
    def create
      if params['orgasm']['caused_by'].present?
        caused_by = User.find_by username: params['orgasm']['caused_by']
        if caused_by.nil?
          redirect_to new_orgasm_path, alert: "User not found."
          return
        end
      end

      @orgasm = Orgasm.new(orgasm_params)
      @orgasm.caused_by = caused_by
      @orgasm.user = current_user

      if @orgasm.save
        Notification.create user: @orgasm.caused_by, notification_type: :orgasm_credited_to_you, text: "#{@orgasm.user.username} attributed an orgasm to you!", link: "/users/#{@orgasm.user.username}" if @orgasm.caused_by.present?
        redirect_to new_orgasm_path, notice: "Orgasm was successfully created."
      else
        redirect_to new_orgasm_path, alert: @orgasm.errors.first.full_message
      end
    end

    # PATCH/PUT /orgasms/1
    def update
      if @orgasm.update(orgasm_params)
        redirect_to @orgasm, notice: "Orgasm was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /orgasms/1
    def destroy
      @orgasm.destroy
      redirect_to orgasms_url, notice: "Orgasm was successfully destroyed."
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_orgasm
      @orgasm = Orgasm.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def orgasm_params
      params.require(:orgasm).permit(:is_ruined, :rating)
    end

    def protected
      redirect_to '/', alert: 'Not authorized' if @orgasm.user.id != current_user.id
    end
  end
end
