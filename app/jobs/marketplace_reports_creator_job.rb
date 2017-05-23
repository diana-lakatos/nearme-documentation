# frozen_string_literal: true
class MarketplaceReportsCreatorJob < Job
  include Job::LongRunning

  def after_initialize(marketplace_report_id)
    @marketplace_report = MarketplaceReport.find(marketplace_report_id)
  end

  def perform
    @marketplace_report.create_report!

    WorkflowStepJob.perform(WorkflowStep::MarketplaceReportWorkflow::Generated, @marketplace_report.id) if @marketplace_report.created?
  end
end
