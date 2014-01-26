class PlatformEmail < ActiveRecord::Base
  validates :email, uniqueness: { case_sensitive: true }
  validates :email, presence: true
  validates :email, email: true

  scope :unnotified, -> {where(notified_at: nil)}
  after_create :enqueue_notification

  def enqueue_notification
    PlatformMailer.enqueue_later(24.hours).email_notification(self)
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
