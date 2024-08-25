class ReportsController < ApplicationController
  before_action :authorize, only: %i[new create]
  before_action :authorize_with_admin, only: %i[index show edit update destroy]
  before_action :set_reportable, only: %i[new create]

  def index
    @reports = Report.where(is_closed: params[:closed].present?).includes(:reporter).limit(100).order(id: :desc)
  end

  def show
    @report = Report.find(params[:id])
  end

  def new
    @report = Report.new(reporter: current_user, reportable: @reportable)
  end

  def create
    @report = Report.new
    @report.reporter = current_user
    @report.reportable = @reportable
    begin
      @report.snapshot = @reportable.snapshot
    rescue
      @report.snapshot = 'Snapshot failed'
    end

    if @report.save
      redirect_to new_polymorphic_path([@reportable, Report]), notice: 'Report was successfully created.'
    else
      redirect_to new_polymorphic_path([@reportable, Report]), alert: 'Report could not be created.'
    end
  end

  def edit

  end

  def update

  end

  def destroy
    @report = Report.find(params[:id])

    if @report
      @report.is_closed = true
      @report.save

      redirect_to mod_tools_report_url(@report), notice: 'Closed ticket'
    else
      redirect_to mod_tools_reports_path, alert: 'Could not archive ticket for some reason. Oh no'
    end
  end

  def set_reportable
    request.path_parameters.each do |key, value|
      if key =~ /_id$/
        resource_name = key.to_s.gsub(/_id$/, "")
        parent_type = resource_name.classify.constantize
        parent_id = value

        @reportable = parent_type.find parent_id
      end
    end
  end
end
