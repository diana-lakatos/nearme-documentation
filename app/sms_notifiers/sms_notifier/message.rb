# Wraps sending a message via the twilio client in an interface
# similar to Mail used in ActionMailer.
class SmsNotifier::Message
  attr_accessor :twilio_sms
  class InvalidTwilioConfig < ::StandardError; end
  class TooLong < ::StandardError; end

  class DummyTwilioClient
    def initialize(key, secret)
      @key = key,
      @secret = secret
    end

    def method_missing(method, *args)
      Rails.logger.info "Twilio #{@key}:#{@secret} - #{method}: #{args.inspect}"
      self
    end
  end

  SMS_SIZE = 160

  def initialize(data)
    @data = data.reverse_merge(from: from_number)
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
    @user ||= User.where(email: fallback_email).first if fallback_email.present? && platform_context.present?
  end

  def deliver
    return if twilio_client.nil?
    validate!

    begin
      send_twilio_message
    rescue Twilio::REST::RequestError => e
      # TODO: use codes instead of messages
      if e.message.include?('is not a valid phone number') || e.message.include?('is not a mobile number')
        fallback_user.notify_about_wrong_phone_number if fallback_user.present?
      else
        raise e
      end
    end
  end
  alias_method :deliver!, :deliver

  private

  def twilio_client
    @twilio_client ||= build_twilio_client
  end

  def build_twilio_client
    raise_error_if_config_invalid
    if Rails.application.config.send_real_sms
      Twilio::REST::Client
    else
      SmsNotifier::Message::DummyTwilioClient
    end.new(config[:key], config[:secret])

  end

  def validate!
    raise SmsNotifier::Message::TooLong.new("SMS size is too long (#{@data[:body].size})") if @data[:body].size > SMS_SIZE unless Rails.env.development?
  end

  def send_twilio_message
    self.twilio_sms = twilio_client.account.sms.messages.create(
      :body => @data[:body],
      :to => @data[:to],
      :from => @data[:from]
    )
  end

  def config
    @config ||= PlatformContext.current.instance.twilio_config
  end

  def from_number
    config[:from]
  end

  def raise_error_if_config_invalid
    if config[:key].blank? || config[:secret].blank? || config[:from].blank?
      raise SmsNotifier::Message::InvalidTwilioConfig.new("Missing key or secret: #{config.inspect}")
    end
  end

end

