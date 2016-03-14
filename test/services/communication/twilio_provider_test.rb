require 'test_helper'

class TwilioProviderTest < ActiveSupport::TestCase

  test '#initialize creates twilio instance' do
    provider = Communication::TwilioProvider.new('key', 'secret')
    assert_equal provider.client.class, Twilio::REST::Client
  end

  test '#verify_number sends request to twilio in order to verify a number' do
    provider = Communication::TwilioProvider.new('key', 'secret')
    provider.client.account.outgoing_caller_ids.expects(:create).with({
      friendly_name: 'name',
      phone_number: '+00000000000',
      status_callback: 'http://example.com/status'
    })

    provider.verify_number('name', '+00000000000', 'http://example.com/status')
  end

  test '#disconnect_number sends request to twilio in order to remove a verified number' do
    provider = Communication::TwilioProvider.new('key', 'secret')
    caller = Struct.new(:delete)

    provider.client.account.outgoing_caller_ids.expects(:get).with('key').returns(caller)
    caller.expects(:delete)

    provider.disconnect_number('key')
  end

  test '#call makes call using personal verified phone number' do
    provider = Communication::TwilioProvider.new('key', 'secret')
    caller = Struct.new(:sid)

    provider.client.account.calls.expects(:create).with(
      from: '+00000000000',
      to: '+11111111111',
      method: 'GET',
      url: 'http://example.com/phoone_calls/connect',
      status_callback_method: 'POST',
      status_callback: 'http://example.com/phone_calls/status'
    ).returns(caller)

    provider.call({
      from: '+00000000000',
      to: '+11111111111',
      url: 'http://example.com/phoone_calls/connect',
      status_callback: 'http://example.com/phone_calls/status'
    })
  end

  test '#hang_up terminates running call' do
    provider = Communication::TwilioProvider.new('key', 'secret')
    caller = Struct.new(:update)

    provider.client.account.calls.expects(:get).with('phone_call_key').returns(caller)
    caller.expects(:update).with(:status => 'completed')

    provider.hang_up('phone_call_key')
  end

end
