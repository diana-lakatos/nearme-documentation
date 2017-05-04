module MarketplaceBuilder
  module BuilderTests
    class ShouldImportPages < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        page = @instance.pages.last
        assert_equal page.content.strip, '<h1>Hello from page!</h1>'
        assert_equal page.slug, 'about-overview'
      end
    end
  end
end
