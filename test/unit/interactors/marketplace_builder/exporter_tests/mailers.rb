module MarketplaceBuilder
  module ExporterTests
    class ShouldExportLiquidViews < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        InstanceView.create!(instance_id: @instance.id, view_type: 'email', path: 'home/index', handler: 'liquid', format: 'html',
                             partial: false, body: 'Hello from email body', locales: Locale.all)

        InstanceView.create!(instance_id: @instance.id, view_type: 'email', path: 'home/index', handler: 'liquid', format: 'text',
                             partial: false, body: 'Hello from text body', locales: Locale.all)
      end

      def execute!
        liquid_content = read_exported_file('mailers/home/index.html.liquid', :liquid)
        assert_equal liquid_content.body, 'Hello from email body'

        liquid_content = read_exported_file('mailers/home/index.text.liquid', :liquid)
        assert_equal liquid_content.body, 'Hello from text body'
      end
    end
  end
end
