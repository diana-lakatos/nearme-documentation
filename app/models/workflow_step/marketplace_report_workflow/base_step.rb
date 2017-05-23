# frozen_string_literal: true
class WorkflowStep::MarketplaceReportWorkflow::BaseStep < WorkflowStep::BaseStep
  def self.belongs_to_transactable_type?
    false
  end

  def initialize(marketplace_report_id)
    @marketplace_report = MarketplaceReport.find_by(id: marketplace_report_id)
    @user = @marketplace_report.creator
    @enquirer = @user
  end

  def workflow_type
    'marketplace_report'
  end

  def data
    {
      marketplace_report: @marketplace_report,
      user: @user
    }
  end

  def should_be_processed?
    @marketplace_report.present?
  end
end
