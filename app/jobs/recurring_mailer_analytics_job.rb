# Sends analytics emails
class RecurringMailerAnalyticsJob < Job

  def perform
    Company.includes(company_users: :user).each do |company|
      company.users.uniq.each do |user|
        next if user.unsubscribed?('recurring_mailer/analytics')
        unless user.administered_locations_pageviews_7_day_total.zero?
          RecurringMailer.enqueue.analytics(company, user)
        end
      end
    end
  end

end
