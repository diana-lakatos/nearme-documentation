require 'sms_notifier'

client = if Rails.env.production? || Rails.env.staging? || Rails.env.development?
  Twilio::REST::Client.new("AC5b979a4ff2aa576bafd240ba3f56c3ce", "0f9a2a5a9f847b0b135a94fe2aa7f346")
else
  # Generate a little fake client that outputs to the Rails logger
  Class.new do
    def method_missing(method, *args)
      if %w(account sms).include?(method.to_s)
        self
      else
        Rails.logger.info "Twilio: #{args.inspect}"
        self
      end
    end
  end.new
end

SmsNotifier::Message.twilio_client = client
SmsNotifier.default_params[:from] = "+1 510-478-9196"

