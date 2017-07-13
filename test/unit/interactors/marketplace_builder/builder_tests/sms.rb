# frozen_string_literal: true
module MarketplaceBuilder
  module BuilderTests
    class ShouldImportSMS < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        liquid_view = @instance.instance_views.where(view_type: 'sms').last
        assert_equal liquid_view.body.strip, 'Hi user!'
        assert_equal liquid_view.path, 'checkout/booking_successful'
        assert_equal liquid_view.format, 'text'
        assert_equal liquid_view.partial, false
      end
    end
  end
end
