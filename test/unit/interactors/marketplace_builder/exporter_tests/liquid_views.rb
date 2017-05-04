module MarketplaceBuilder
  module ExporterTests
    class ShouldExportLiquidViews < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        InstanceView.create!(instance_id: @instance.id, view_type: 'view', path: 'home/index', handler: 'liquid', format: 'html',
                             partial: false, body: 'Hello from liquid view', locales: Locale.all)
      end

      def execute!
        liquid_content = read_exported_file('liquid_views/home/index.liquid', :liquid)
        assert_equal liquid_content.body, 'Hello from liquid view'
      end
    end
  end
end
