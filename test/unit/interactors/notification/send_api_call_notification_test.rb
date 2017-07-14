# frozen_string_literal: true
require 'test_helper_lite'
require 'mocha/setup'
require 'mocha/mini_test'
require 'webmock/minitest'

module Notification
  class SendApiCallNotificationTest < ActiveSupport::TestCase
    context 'call' do
      should 'should send api_call within standard layout' do
        Notification::SendNotification.stubs(:notification_class)
                                      .returns(Notification::SendApiCallNotification)

        stub_request(:post, 'https://example.com/user_updates/val')
          .with(body: '{ field: val, greetiing: hi }',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Content-Type' => 'application/json',
                           'Host' => 'example.com',
                           'User-Agent' => 'Ruby' })
          .to_return(status: 200, body: '', headers: {})
        Notification::SendNotification.call(notification: notification,
                                            form: dummy_form,
                                            params: params)
      end
    end

    protected

    def notification
      OpenStruct.new(
        name: 'send_hello_api_call',
        to: 'https://example.com/user_updates/{{ form.field }}',
        content: '{ field: {{ form.field }}, greetiing: {{ params.greeting }} } ',
        request_type: 'POST',
        format: 'http',
        trigger_condition: 'true',
        headers: '{"Content-Type": "application/json"}'
      )
    end

    def dummy_form
      {
        'field' => 'val'
      }
    end

    def params
      {
        'greeting' => 'hi'
      }
    end
  end
end
