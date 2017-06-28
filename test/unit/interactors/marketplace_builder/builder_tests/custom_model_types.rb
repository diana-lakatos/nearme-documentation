module MarketplaceBuilder
  module BuilderTests
    class ShouldImportCustomModelTypes < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        custom_model = CustomModelType.where(instance_id: @instance.id).last
        assert_equal 'Vehicles', custom_model.name
      end
    end
  end
end
