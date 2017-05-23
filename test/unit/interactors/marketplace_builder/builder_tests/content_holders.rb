module MarketplaceBuilder
  module BuilderTests
    class ShouldImportContentHolders < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        content_holder = ContentHolder.last
        assert_equal content_holder.name, 'Custom JS'
        assert_equal content_holder.content.strip, '<script src="http://lvh.me:8080/app.js"></script>'
        assert_equal content_holder.enabled, true
        assert_equal content_holder.inject_pages, ['any_page']
        assert_equal content_holder.position, 'body_bottom'
      end
    end
  end
end
