module MarketplaceBuilder
  module ExporterTests
    class ShouldExportContentHolder < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        ContentHolder.create!(instance_id: @instance.id,
                              name: 'Custom JS',
                              content: '<script src="http://lvh.me:8080/app.js"></script>',
                              enabled: true,
                              inject_pages: ['any_page'],
                              position: 'body_bottom')
      end

      def execute!
        liquid_content = read_exported_file('content_holders/custom_js.liquid', :liquid)
        assert_equal liquid_content.body, '<script src="http://lvh.me:8080/app.js"></script>'
        assert_equal liquid_content.name, 'Custom JS'
        assert_equal liquid_content.enabled, true
        assert_equal liquid_content.inject_pages, ['any_page']
        assert_equal liquid_content.position, 'body_bottom'
      end
    end
  end
end
