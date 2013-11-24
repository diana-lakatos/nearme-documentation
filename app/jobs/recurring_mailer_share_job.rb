# Sends share emails
class RecurringMailerShareJob < Job

  def initialize
    @sent_to_users = []
  end

  def perform
    Listing.searchable.each do |listing|
      next if listing.administrator.unsubscribed?('recurring_mailer/share')
      next if @sent_to_users.include?(listing.administrator.id)

      listing_last_booked_days = listing.last_booked_days
      if listing_last_booked_days.to_i > 0 && (listing_last_booked_days % 21).zero?
        @sent_to_users << listing.administrator.id
        RecurringMailer.enqueue.share(listing)
      end
    end
  end

end
