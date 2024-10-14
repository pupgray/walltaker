class SurveyResponsesController < ApplicationController
  before_action :set_survey, only: [:index, :create]
  before_action :set_survey_response, only: [:update, :show]
  before_action :authorize, only: [:update]
  before_action :only_survey_owner, only: [:update]

  def index
  end

  def show
  end

  def create
    @response = SurveyResponse.create(survey: @survey, user: current_user)
    form_element_ids = @survey.form_elements.pluck(:id)
    possible_params = form_element_ids.map {|id| "form_element_#{id}"}
    params.each do |k, v|
      if possible_params.include?(k)
        id = k.split('_').last.to_i
        @response.answers.create(form_element_id: id, value: v)
      end
    end

    if @response.save
      redirect_to survey_path(@survey), notice: 'Response saved successfully'
    else
      redirect_to survey_path(@survey), alert: 'Something went wrong'
    end
  end

  def update
    if @response.update(survey_params)
      redirect_to survey_responses_path(@response.survey), notice: 'Comment published!'
    else
      redirect_to survey_response_path(@response), alert: 'Something went wrong'
    end
  end

  private

  def set_survey
    @survey = Survey.find(params[:survey_id])
  end

  def set_survey_response
    @response = SurveyResponse.find(params[:id])
  end

  def survey_params
    params.require(:survey_response).permit(:comment)
  end

  def only_survey_owner
    valid = @response.survey.user == current_user

    redirect_to root_path unless valid
  end
end
