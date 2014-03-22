class PayoutVerificationJob < MailerJob

  def after_initialize(processor)
    @processor = processor
  end

  def perform
    @processor.update_payout_status
  end
end
