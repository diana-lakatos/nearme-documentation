module MarketplaceBuilder
  module BuilderTests
    class ShouldImportMailers < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        liquid_view = @instance.instance_views.where(view_type: 'email').last
        assert_equal liquid_view.body.strip, '<h1>Hi user!</h1>'
        assert_equal liquid_view.path, 'checkout/booking_successful'
      end
    end
  end
end
