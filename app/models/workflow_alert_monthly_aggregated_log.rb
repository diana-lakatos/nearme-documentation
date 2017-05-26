class WorkflowAlertMonthlyAggregatedLog < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  has_many :workflow_alerts
  belongs_to :instance

  def self.find_or_create_for_current_month
    retries ||= 0

    where(instance_id: PlatformContext.current.instance.id, year: Time.zone.now.year, month: Time.zone.now.month).first_or_create
  rescue ActiveRecord::RecordNotUnique
    retries += 1
    retries <= 5 ? retry : raise
  end
end
