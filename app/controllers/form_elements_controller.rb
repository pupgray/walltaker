class FormElementsController < ApplicationController
  before_action :set_form_element, only: %i[ show edit update destroy nudge summary ]
  before_action :set_survey, except: %i[single_response]
  before_action :authorize, except: %i[ show single_response ]
  before_action :must_own_survey, only: %i[edit update destroy]

  # GET /form_elements/1 or /form_elements/1.json
  def show
  end

  def summary
  end

  def single_response
    @form_element = FormElement.find(params[:form_element_id])
    @response = SurveyResponse.find(params[:id])
    @answer = @response.answers.where(form_element: @form_element).first

    expires_in 72.hours
  end

  # GET /form_elements/new
  def new
    @form_element = @survey.form_elements.new
  end

  # GET /form_elements/1/edit
  def edit
    render turbo_stream: turbo_stream.update('form_element_modal', partial: 'form_elements/form', locals: { form_element: @form_element })
  end

  def nudge
    direction = params[:direction] == "up" ? "up" : "down"

    last_order = @survey.form_elements.pluck(:sort_order).last || 0

    case direction
    when "up"
      prior_element = @survey.form_elements.where('sort_order < ?', @form_element.sort_order).last
    when "down"
      prior_element = @survey.form_elements.where('sort_order > ?', @form_element.sort_order).first
    else
      return redirect_to survey_path(@survey), alert: 'No direction provided?'
    end

    if prior_element.nil?
      head 200, content_type: "text/html"
    else
      @form_element.transaction do
        original_order = @form_element.sort_order
        @form_element.sort_order = prior_element.sort_order
        prior_element.sort_order = last_order + 1
        prior_element.save!
        @form_element.save!
        prior_element.sort_order = original_order
        prior_element.save!
      end

      streams = [
        turbo_stream.replace(@form_element, partial: 'form_elements/form_element', locals: { form_element: prior_element, edit: true }),
        turbo_stream.replace(prior_element, partial: 'form_elements/form_element', locals: { form_element: @form_element, edit: true })
      ]

      streams.reverse! if direction == "down"

      render turbo_stream: streams
    end
  end

  # POST /form_elements or /form_elements.json
  def create
    @form_element = @survey.form_elements.new(form_element_params)
    last_order = @survey.form_elements.pluck(:sort_order).last || 0
    @form_element.sort_order = last_order + 1

    if @form_element.save
      render turbo_stream: turbo_stream.append('survey', partial: 'form_elements/form_element', locals: { form_element: @form_element, edit: true })
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /form_elements/1 or /form_elements/1.json
  def update
    if @form_element.update(form_element_params)
      render turbo_stream: turbo_stream.replace(@form_element, partial: 'form_elements/form_element', locals: { form_element: @form_element, edit: true })
    else
      render turbo_stream: turbo_stream.replace(@form_element, partial: 'form_elements/form', locals: { form_element: @form_element })
    end
  end

  # DELETE /form_elements/1 or /form_elements/1.json
  def destroy
    @form_element.destroy!

    render turbo_stream: turbo_stream.remove(@form_element)
  end

  private

  def set_form_element
    @form_element = FormElement.find(params[:id])
  end

  def set_survey
    @survey = Survey.find(params[:survey_id])
    redirect_to survey_path(@survey), alert: "Form element is not part of that form" if @form_element && @form_element.survey != @survey
  end

  def must_own_survey
    valid = current_user.surveys.find(@form_element.survey.id).present?

    redirect_to root_url, alert: "Not authorized" unless valid
  end

  # Only allow a list of trusted parameters through.
  def form_element_params
    params.require(:form_element).permit(:label, :kind, :required)
  end
end
