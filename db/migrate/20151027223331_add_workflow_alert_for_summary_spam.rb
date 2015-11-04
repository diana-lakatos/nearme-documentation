class AddWorkflowAlertForSummarySpam < ActiveRecord::Migration
  def change
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)
      Utils::DefaultAlertsCreator::SpamReportCreator.new.create_all!
    end
  end
end
