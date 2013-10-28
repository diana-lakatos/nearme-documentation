require 'sms_notifier'

if Rails.env.production?
  # This is the number from the Numbers section in the Twilio account.
  SmsNotifier.default_params[:from] = "+1 510-478-9196"
  SmsNotifier::Message.twilio_client = Twilio::REST::Client.new("AC5b979a4ff2aa576bafd240ba3f56c3ce", "0f9a2a5a9f847b0b135a94fe2aa7f346")
elsif Rails.env.development? || Rails.env.staging?
  # This is the test number which successfully sends
  SmsNotifier.default_params[:from] = "+15005550006"
  SmsNotifier::Message.twilio_client = Twilio::REST::Client.new("AC83d13764f96b35292203c1a276326f5d", "709625e20011ace4b8b53a5a04160026")
else
  # Generate a little fake client that outputs to the Rails logger
  SmsNotifier::Message.twilio_client = Class.new do
    def method_missing(method, *args)
      Rails.logger.info "Twilio: #{args.inspect}"
      self
    end
  end.new
end
