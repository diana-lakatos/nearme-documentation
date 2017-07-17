# frozen_string_literal: true
module MarketplaceBuilder
  module BuilderTests
    class ShouldImportEmailNotifications < ActiveSupport::TestCase
      def initialize(_instance)
        @email_notification = EmailNotification.find_by(name: 'some_email_notification')
        @forced_email_notification = EmailNotification.find_by(name: 'forced_email_notification')
      end

      def execute!
        assert_email_notification(@email_notification, forced: false)
        assert_email_notification(@forced_email_notification, forced: true)
      end

      def assert_email_notification(email_notification, forced: false)
        assert_not_nil email_notification
        assert_equal "#{forced ? 'forced' : 'some'}_email_notification", email_notification.name
        assert_equal '{{ form.model.email }}', email_notification.to
        assert_equal 'Hello {{ form.model.first_name }}', email_notification.content.strip
        assert_equal 30, email_notification.delay
        assert email_notification.enabled
        assert_equal 'lack of condition', email_notification.trigger_condition
        assert_equal 'from@near-me.com', email_notification.from
        assert_equal 'reply_to@near-me.com', email_notification.reply_to
        assert_equal 'cc@near-me.com', email_notification.cc
        assert_equal 'bcc@near-me.com', email_notification.bcc
        assert_equal 'Hi {{ form.model.first_name }}', email_notification.subject
        assert_equal 'my_layout', email_notification.layout_path
        assert_equal forced, email_notification.forced?
      end
    end
  end
end
