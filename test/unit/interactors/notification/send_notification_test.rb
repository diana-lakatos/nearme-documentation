# frozen_string_literal: true
require 'test_helper_lite'
require 'mocha/setup'
require 'mocha/mini_test'

module Notification
  class SendNotificationTest < ActiveSupport::TestCase
    class SendDummyNotification < SendNotification
      def send
        true
      end

      def mandatory_fields
        %i(arg1 arg2)
      end
    end

    setup do
      Notification::SendNotification.stubs(:notification_class)
                                    .returns(SendDummyNotification)
    end
    context 'call' do
      should 'should send if all ok' do
        SendDummyNotification.any_instance.expects(:send).once
        SendDummyNotification.any_instance.stubs(:log_error).never
        send_notification(notification)
      end

      should 'raise error if mandatory field is missing' do
        SendDummyNotification.any_instance.stubs(:send).never
        SendDummyNotification.any_instance.stubs(:log_error).once
        send_notification(notification_without_arg2)
      end

      should 'not be triggered if trigger condition is not true' do
        SendDummyNotification.any_instance.stubs(:send).never
        send_notification(notification_without_trigger_condition)
      end

      should 'respect locale' do
        I18n.locale = :en
        send_notification(notification)
        assert_equal :de, I18n.locale
      end
    end

    protected

    def send_notification(notification)
      Notification::SendNotification.call(notification: notification, form: {}, params: {})
    end

    def notification
      OpenStruct.new(
        arg1: 'something',
        arg2: 'something',
        locale: 'de', trigger_condition: 'true'
      )
    end

    def notification_without_trigger_condition
      OpenStruct.new(
        arg1: 'something',
        arg2: 'something',
        locale: 'de', trigger_condition: ''
      )
    end

    def notification_without_arg2
      OpenStruct.new(
        arg1: 'something',
        locale: 'de', trigger_condition: 'true'
      )
    end
  end
end
