module MarketplaceBuilder
  module ExporterTests
    class ShouldExportPages < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        Page.create!(instance_id: @instance.id, slug: 'about-us', content: 'Hello from page', path: 'about-us')
      end

      def execute!
        liquid_content = read_exported_file('pages/about-us.liquid', :liquid)
        assert_equal liquid_content.body, 'Hello from page'
        assert_equal liquid_content.slug, 'about-us'
      end
    end
  end
end
