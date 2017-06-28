module MarketplaceBuilder
  module BuilderTests
    class ShouldImportMailers < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        liquid_view = @instance.instance_views.where(view_type: 'email', format: 'html').last
        assert_equal liquid_view.body.strip, '<h1>Hi user!</h1>'
        assert_equal liquid_view.path, 'checkout/booking_successful'
        assert_equal liquid_view.format, 'html'

        liquid_view = @instance.instance_views.where(view_type: 'email', format: 'text').last
        assert_equal liquid_view.body.strip, 'Hi user!'
        assert_equal liquid_view.path, 'checkout/booking_successful'
        assert_equal liquid_view.format, 'text'
      end
    end
  end
end
