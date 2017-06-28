# frozen_string_literal: true
require 'test_helper_lite'
require 'mocha/setup'
require 'mocha/mini_test'

module Notification
  class SendEmailNotificationTest < ActiveSupport::TestCase
    context 'call' do
      should 'should send email within standard layout' do
        Notification::SendNotification.stubs(:notification_class)
                                      .returns(Notification::SendEmailNotification)
        email = Notification::SendNotification.call(notification: notification,
                                                    form: dummy_form,
                                                    params: params)
        assert_equal ['a@example.com'], email.to
        assert_equal ['b@example.com'], email.from
        assert_equal ['c@example.com'], email.reply_to
        assert_equal %w(cc1@example.com cc2@example.com), email.cc
        assert_equal %w(bcc1@example.com bcc2@example.com), email.bcc
        assert_equal 'val :)', email.subject

        # includes layout
        assert email.html_part.body.include?('You are receiving this email because you signed up to')
        assert email.html_part.body.include?('Hello from field val</h1>')
        assert email.html_part.body.include?('Parameter says hi')
      end

      should 'should respect when user unsubscribed' do
        Notification::SendNotification.stubs(:notification_class)
                                      .returns(Notification::SendEmailNotification)

        Notification::SendEmailNotification.any_instance.stubs(:unsubscribed_emails).returns(
          %w(cc1@example.com c@example.com b@example.com a@example.com)
        )
        email = Notification::SendNotification.call(notification: notification,
                                                    form: dummy_form,
                                                    params: params)
        assert_equal [], email.to
        assert_equal ['b@example.com'], email.from
        assert_equal ['c@example.com'], email.reply_to
        assert_equal %w(cc2@example.com), email.cc
        assert_equal %w(bcc1@example.com bcc2@example.com), email.bcc
      end
    end

    protected

    def notification
      OpenStruct.new(
        to: 'a@example.com',
        from: 'b@example.com',
        reply_to: 'c@example.com',
        cc: '{% assign ccs = \'cc1@example.com|cc2@example.com\' | split: \'|\'%}{{ ccs | join: \',\'  }}',
        bcc: '{% assign bccs = \'bcc1@example.com|bcc2@example.com\' | split: \'|\'%}{{ bccs | join: \',\'  }}',
        locale: 'de', trigger_condition: 'true', layout_path: 'mailer',
        content: '<h1>Hello from field {{ form.field }}</h1>. Parameter says {{ params.greeting  }}',
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
