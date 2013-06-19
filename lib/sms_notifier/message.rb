# Wraps sending a message via the twilio client in an interface
# similar to Mail used in ActionMailer.
class SmsNotifier::Message
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
end


