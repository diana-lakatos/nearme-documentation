class WorkflowAlertWeeklyAggregatedLog < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  has_many :workflow_alerts
  belongs_to :instance

  def self.find_or_create_for_current_week
    where(instance_id: PlatformContext.current.instance.id, year: Time.zone.now.year, week_number: Time.zone.now.strftime('%U').to_i).first_or_create!
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
