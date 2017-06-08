module MarketplaceBuilder
  module BuilderTests
    class ShouldImportInstanceProfileTypes < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        assert_equal 'Default', @instance.default_profile_type.name
      end
    end
  end
end
