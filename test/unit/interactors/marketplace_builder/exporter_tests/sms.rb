# frozen_string_literal: true
module MarketplaceBuilder
  module ExporterTests
    class ShouldExportSMS < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        InstanceView.create!(instance_id: @instance.id, view_type: 'sms', path: 'home/index', handler: 'liquid', format: 'text',
                             partial: false, body: 'Hello from text body', locales: Locale.all)
      end

      def execute!
        liquid_content = read_exported_file('sms/home/index.liquid', :liquid)
        assert_equal liquid_content.body, 'Hello from text body'
      end
    end
  end
end
