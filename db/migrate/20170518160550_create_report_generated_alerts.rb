class CreateReportGeneratedAlerts < ActiveRecord::Migration
  def self.up
    Instance.find_each do |i|
      i.set_context!

      Utils::DefaultAlertsCreator::MarketplaceReportCreator.new.create_all!
    end
  end

  def self.down
    Instance.find_each do |i|
      i.set_context!

      WorkflowStep.find_by(associated_class: 'WorkflowStep::MarketplaceReportWorkflow::Generated').destroy
    end
  end
end
