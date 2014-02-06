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

  private

  def twilio_client
    self.class.twilio_client
  end

  def validate!
    raise SmsNotifier::Message::TooLong.new("SMS size is too long (#{@data[:body].size})") if @data[:body].size > SMS_SIZE
  end
end


