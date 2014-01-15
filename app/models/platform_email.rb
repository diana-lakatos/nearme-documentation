class PlatformEmail < ActiveRecord::Base
  EMAIL_VALIDATOR = %r{^(?:[_a-z0-9\-\+]+)(\.[_a-z0-9\-\+]+)*@([a-z0-9\-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i

  validates :email, uniqueness: { case_sensitive: true }
  validates :email, presence: true
  validates_format_of :email, with: EMAIL_VALIDATOR, multiline: true

  scope :unnotified, -> {where(notified_at: nil)}
  after_create :enqueue_notification

  def enqueue_notification
    PlatformMailer.delay(run_at: 24.hours.from_now).email_notification(self)
    touch(:notified_at)
  end

  def unsubscribed?
    !unsubscribed_at.nil?
  end

  def subscribed?
    unsubscribed_at.nil?
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
