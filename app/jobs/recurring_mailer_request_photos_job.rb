# Sends request_photos emails
class RecurringMailerRequestPhotosJob < Job

  def after_initialize
    @sent_to_users = []
  end

  def perform
    Transactable.searchable.includes(:photos).each do |listing|
      PlatformContext.current = PlatformContext.new(listing.company)
      next unless listing.administrator
      next if listing.administrator.unsubscribed?('recurring_mailer/request_photos')
      next if @sent_to_users.include?(listing.administrator.id)
      next if listing.photos_metadata.try(:count).to_i > 1

      last_sent_days = days_from(listing.last_request_photos_sent_at)
      listing_activated_days = days_from(listing.activated_at)

      # Send for listings with <= 1 photos, every 28 days at most per listing, for listings that have been active at least 7 days.
      if (last_sent_days.nil? || (last_sent_days % 28).zero?) && listing_activated_days.to_i >= 7
        @sent_to_users << listing.administrator.id
        WorkflowStepJob.perform(WorkflowStep::RecurringWorkflow::RequestPhotos, listing.id)
        listing.last_request_photos_sent_at = Time.zone.now
        listing.save(validate: false)
      end
    end
  end

  private

  def days_from(date)
    date ? ((Time.current.to_f - date.to_f) / 1.day.to_f).round : nil
  end
end
