# Sends analytics emails
class RecurringMailerAnalyticsJob < Job
  def perform
    Company.includes(company_users: :user).each do |company|
      PlatformContext.current = PlatformContext.new(company)
      company.users.uniq.each do |user|
        next if user.unsubscribed?('recurring_mailer/analytics')
        unless user.administered_locations_pageviews_30_day_total.zero?
          WorkflowStepJob.perform(WorkflowStep::RecurringWorkflow::Analytics, company.id, user.id)
        end
      end
    end
  end
end
