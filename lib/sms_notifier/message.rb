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

  def platform_context
    PlatformContext.current
  end

  def fallback_email
    @data.fetch(:fallback, {}).fetch(:email, nil)
  end

  def fallback_user
    @user ||= begin
                User.where(email: fallback_email).first if fallback_email.present? && platform_context.present?
              end
  end

  def deliver
    validate!

    begin
      send_twilio_message
    rescue Twilio::REST::RequestError => e
      if e.message.include?('is not a valid phone number')
        fallback_user.notify_about_wrong_phone_number if fallback_user.present?
      else
        Rails.logger.error "Sending #{caller[0]} SMS to #{@data[:to]} failed at #{Time.zone.now}. #{$!.inspect}"
      end
    end
  end
  alias_method :deliver!, :deliver

  private

  def twilio_client
    self.class.twilio_client
  end

  def validate!
    raise SmsNotifier::Message::TooLong.new("SMS size is too long (#{@data[:body].size})") if @data[:body].size > SMS_SIZE
  end

  def send_twilio_message
    twilio_client.account.sms.messages.create(
      :body => @data[:body],
      :to => @data[:to],
      :from => @data[:from]
    )
  end
end


