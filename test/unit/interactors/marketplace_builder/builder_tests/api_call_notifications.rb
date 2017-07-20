# frozen_string_literal: true
module MarketplaceBuilder
  module BuilderTests
    class ShouldImportApiCallNotifications < ActiveSupport::TestCase
      def initialize(_instance)
        @email_notification = ApiCallNotification.find_by(name: 'api_notification')
      end

      def execute!
        assert_not_nil @email_notification
        assert_equal 'api_notification', @email_notification.name
        assert_equal 'https://example.com/endpoint/{{ form.model.id }}', @email_notification.to
        assert_equal '{
  "name": "{{ form.model.first_name }}",
  "id": "{{ form.model.id }}"
}', @email_notification.content.strip
        assert_equal 30, @email_notification.delay
        assert @email_notification.enabled
        assert_equal 'lack of condition', @email_notification.trigger_condition
        assert_equal 'DELETE', @email_notification.request_type
        assert_equal 'http', @email_notification.format
        assert_equal '{ "Cache-Control": "no-cache", "Content-Type": "application/json" }', @email_notification.headers
      end
    end
  end
end
