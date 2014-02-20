# Wraps sending a message via the twilio client in an interface
# similar to Mail used in ActionMailer.
class SmsNotifier::Message
  class TooLong < ::StandardError
    def initialize(msg)
      super
    end
  end

  SMS_SIZE = 160

  # Assign the twilio client in an initializer
  class_attribute :twilio_client

  def initialize(data)
    @data = data
  end

  def to
    @data[:to]
  end

  def from
    @data[:from]
  end

  def body
    @data[:body]
  end

  def deliver
    validate!

    twilio_client.account.sms.messages.create(
      :body => @data[:body],
      :to => @data[:to],
      :from => @data[:from]
    )
  end
  alias_method :deliver!, :deliver

  def deliver_with_context(platform_context, user, error_message = '')
    begin
      deliver
    rescue Twilio::REST::RequestError => e
      if e.message.include?('is not a valid phone number')
        user.notify_about_wrong_phone_number(platform_context)
      else
        BackgroundIssueLogger.log_issue("[internal] twilio error - #{e.message}", "support@desksnear.me", "#{error_message} #{$!.inspect}")
      end
    end
  end

  private

  def twilio_client
    self.class.twilio_client
  end

  def validate!
    raise SmsNotifier::Message::TooLong.new("SMS size is too long (#{@data[:body].size})") if @data[:body].size > SMS_SIZE
  end
end


