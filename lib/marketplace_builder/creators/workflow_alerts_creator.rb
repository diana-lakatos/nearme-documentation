# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class WorkflowAlertsCreator < DataCreator
      def execute!
        alert_groups = get_data
        return if alert_groups.empty?

        alert_groups.each do |group, alert_types|
          begin
            klass = "Utils::DefaultAlertsCreator::#{group.classify}Creator".constantize
            raise NameError unless klass.is_a?(Class)
          rescue NameError
            raise MarketplaceBuilder::Error, "#{group} is not a valid workflow alert group name"
          end

          logger.info "Creating workflow alerts for: #{group.classify}"

          alert_creator = klass.new

          alert_types.each do |alert_type|
            method_name = "create_#{alert_type}!".to_sym
            raise MarketplaceBuilder::Error, "#{alert_type} is not a valid alert type for #{group} alert group" unless alert_creator.respond_to?(method_name)
            logger.debug "Creating workflow alert type: #{group}:#{alert_type}"
            alert_creator.send(method_name)
          end
        end
      end

      private

      def source
        File.join('workflow_alerts', 'workflow_alerts.yml')
      end
    end
  end
end
