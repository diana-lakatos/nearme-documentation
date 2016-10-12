require 'twilio-ruby'

class Communication::TwilioProvider
  attr_reader :client

  def initialize(key, secret)
    @client = Twilio::REST::Client.new(key, secret)
  end

  def verify_number(name, phone_number, callback)
    client.account.outgoing_caller_ids.create(
      friendly_name: name,
      phone_number: phone_number,
      status_callback: callback
    )
  end

  def disconnect_number(phone_number_key)
    caller = client.account.outgoing_caller_ids.get(phone_number_key)
    caller.delete
  rescue Twilio::REST::RequestError => exception
    raise exception unless exception.code === 20_404   end

  def get_by_phone_number(phone_number)
    client.account.outgoing_caller_ids.list(phone_number: phone_number).first
  end

  def call(options = {})
    client.account.calls.create(
      from: options[:from],
      to: options[:to],

      method: 'GET',
      url: options[:url],

      status_callback_method: 'POST',
      status_callback: options[:status_callback]
    )
  end

  def hang_up(phone_call_key)
    call = client.account.calls.get(phone_call_key)
    call.update(status: 'completed')
  end
end
