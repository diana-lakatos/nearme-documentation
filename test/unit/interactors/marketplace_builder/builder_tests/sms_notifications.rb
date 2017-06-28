# frozen_string_literal: true
module MarketplaceBuilder
  module BuilderTests
    class ShouldImportSmsNotifications < ActiveSupport::TestCase
      def initialize(_instance)
        @sms_notification = SmsNotification.find_by(name: 'some_sms')
      end

      def execute!
        assert_not_nil @sms_notification
        assert_equal 'some_sms', @sms_notification.name
        assert_equal '{{ form.model.full_mobile_number }}', @sms_notification.to
        assert_equal 'Hello {{ form.model.first_name }}', @sms_notification.content.strip
        assert_equal 30, @sms_notification.delay
        assert @sms_notification.enabled
        assert_equal 'lack of condition', @sms_notification.trigger_condition
      end
    end
  end
end
