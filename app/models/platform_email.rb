class PlatformEmail < ActiveRecord::Base
  EMAIL_VALIDATOR = %r{^(?:[_a-z0-9\-\+]+)(\.[_a-z0-9\-\+]+)*@([a-z0-9\-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i

  validates :email, uniqueness: { case_sensitive: true }
  validates :email, presence: true
  validates_format_of :email, with: EMAIL_VALIDATOR, multiline: true

  scope :unnotified, -> {where(notified_at: nil)}
  # after_create :enqueue_notification

  def enqueue_notification(perform_at = NearMe.settings.perform_email_notification_at)
    if email =~ /engineering(\+\w+)?@desksnear.me/
      enqueue_test_notification
    else
      return false if Time.now < NearMe.settings.send_email_notification_after_date
      EmailMailer.delay(run_at: Time.now + perform_at).notification(self)
      touch(:notified_at)
    end
  end

  # Just for testing
  def enqueue_test_notification
    EmailMailer.delay(run_at: Time.now).notification(self, 'engineering@desksnear.me')
  end

  def unsubscribed?
    !unsubscribed_at.nil?
  end

  def unsubscribe!
    self.unsubscribed_at = Time.now
    save!
  end

  def resubscribe!
    self.unsubscribed_at = nil
    save!
  end
end
