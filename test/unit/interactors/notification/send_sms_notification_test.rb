# frozen_string_literal: true
require 'test_helper_lite'
require 'mocha/setup'
require 'mocha/mini_test'

module Notification
  class SendSmsNotificationTest < ActiveSupport::TestCase
    context 'call' do
      should 'should send sms within standard layout' do
        SmsNotifier::Message.any_instance.stubs(:config).returns(key: 'AC83d13764f96b35292203c1a276326f5d',
                                                                 secret: '709625e20011ace4b8b53a5a04160026',
                                                                 from: '+15005550006')
        Notification::SendNotification.stubs(:notification_class)
                                      .returns(Notification::SendSmsNotification)
        sms = Notification::SendNotification.call(notification: notification,
                                                  form: dummy_form,
                                                  params: params)
        assert_equal 'a@example.com', sms.to
        assert_equal '+15005550006', sms.from
        assert sms.body.include?('Hello from field val. Parameter says hi')
      end
    end

    protected

    def notification
      OpenStruct.new(
        to: 'a@example.com',
        locale: 'de', trigger_condition: 'true',
        content: 'Hello from field {{ form.field }}. Parameter says {{ params.greeting  }}',
        subject: '{{ form.field }} :)'
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
