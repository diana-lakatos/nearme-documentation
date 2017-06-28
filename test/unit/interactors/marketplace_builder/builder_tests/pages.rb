module MarketplaceBuilder
  module BuilderTests
    class ShouldImportPages < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        page = @instance.pages.last
        assert_equal '<h1>Hello from page!</h1>', page.content.strip
        assert_equal 'about-overview', page.slug
        assert_equal %w(page_policy), page.authorization_policies.pluck(:name)
      end
    end
  end
end
