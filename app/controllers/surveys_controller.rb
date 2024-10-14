class SurveysController < ApplicationController
  before_action :set_survey, only: %i[ show edit update destroy ]
  before_action :authorize, except: %i[index show]
  before_action :must_own_survey, only: %i[edit update destroy]

  # GET /forms or /forms.json
  def index
    @user = User.find_by_username(params[:user_id])
    @surveys = @user.surveys.all
  end

  # GET /forms/1 or /forms/1.json
  def show
  end

  # GET /forms/new
  def new
    @survey = Survey.new
  end

  # GET /forms/1/edit
  def edit
  end

  # POST /forms or /forms.json
  def create
    @survey = Survey.new(form_params)
    @survey.user = current_user

    if @survey.save
      redirect_to (@survey), notice: "Form was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /forms/1 or /forms/1.json
  def update
    if @survey.update(form_params)
      redirect_to edit_survey_path(@survey), notice: "Form was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /forms/1 or /forms/1.json
  def destroy
    @survey.destroy!

    redirect_to user_surveys_path(current_user.username), notice: "Form was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_survey
    @survey = Survey.find(params[:id])
  end

  def must_own_survey
    valid = current_user.surveys.find(@survey.id).present?

    redirect_to root_url, alert: "Not authorized" unless valid
  end

  # Only allow a list of trusted parameters through.
  def form_params
    params.require(:survey).permit(:title, :description, :public)
  end
end
