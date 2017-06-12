module MarketplaceBuilder
  module BuilderTests
    class ShouldImportReservationTypes < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        assert_equal 'Booking', @instance.reservation_types.last.name
      end
    end
  end
end
