# frozen_string_literal: true
class InappropriateReportsController < ApplicationController
  before_action :find_reportable

  def create
    @report = InappropriateReport.new(reportable: @reportable, user: current_user,
                                      ip_address: request.remote_ip,
                                      reason: params[:inappropriate_report][:reason])
    if @report.save
      flash[:notice] = t('inappropriate_reports.report_has_been_sent')
      WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::InappropriateReported, @report.id, as: current_user)
    else
      flash[:error] = t('inappropriate_reports.please_fill_in_reason')
    end
    redirect_to @reportable.decorate.show_path
  end

  def show
    render partial: 'shared/components/flag_as_inappropriate'
  end

  private

  def find_reportable
    # For now we allow just Transactables and Users
    raise ArgumentError, "Invalid reportable_type: #{params[:reportable_type]}. Valid reportable types are: Transactable, User" unless %w(Transactable User).include?(params[:reportable_type])
    @reportable = params[:reportable_type].constantize.find(params[:id])
  end
end
