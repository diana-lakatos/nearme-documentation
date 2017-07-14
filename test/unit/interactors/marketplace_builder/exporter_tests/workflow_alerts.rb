# frozen_string_literal: true
require_relative 'basic'

module MarketplaceBuilder
  module ExporterTests
    class ShouldExportWorkflowAlerts < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        WorkflowAlert.create!(name: 'Standalone workflow alert',
                              recipient: 'maciek@near-me.com',
                              alert_type: 'email',
                              template_path: 'standalone_mailer/example')
      end

      def execute!
        yaml_content = read_exported_file('workflow_alerts/standalone_workflow_alert.yml')

        assert_equal yaml_content, 'name' => 'Standalone workflow alert',
                                   'alert_type' => 'email',
                                   'delay' => 0,
                                   'enabled' => true,
                                   'headers' => '{}', 'payload_data' => '{}',
                                   'prevent_trigger_condition' => '',
                                   'recipient' => 'maciek@near-me.com',
                                   'template_path' => 'standalone_mailer/example'
      end
    end
  end
end
