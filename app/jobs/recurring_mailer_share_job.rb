# Sends share emails
class RecurringMailerShareJob < Job
  def after_initialize
    @sent_to_users = []
  end

  def perform
    Transactable.searchable.each do |listing|
      PlatformContext.current = PlatformContext.new(listing.company)
      next unless listing.administrator
      next if listing.administrator.unsubscribed?('recurring_mailer/share')
      next if @sent_to_users.include?(listing.administrator.id)

      listing_last_booked_days = listing.last_booked_days
      if listing_last_booked_days.to_i > 0 && (listing_last_booked_days % 21).zero?
        @sent_to_users << listing.administrator.id
        WorkflowStepJob.perform(WorkflowStep::RecurringWorkflow::Share, listing.id)
      end
    end
  end
end
