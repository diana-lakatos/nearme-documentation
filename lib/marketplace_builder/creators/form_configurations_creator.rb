# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class FormConfigurationsCreator < TemplatesCreator
      def cleanup!
        form_configurations = get_templates
        return @instance.form_configurations.destroy_all if form_configurations.empty?

        unused_form_configurations = if form_configurations.empty?
                                       @instance.form_configurations.all
                                     else
                                       @instance.form_configurations.where('name NOT IN (?)', form_configurations.map(&:name))
                       end

        unused_form_configurations.each { |form_configuration| logger.debug "Removing unused form_configuration: #{form_configuration.name}" }
        unused_form_configurations.destroy_all
      end

      private

      def object_name
        'FormConfiguration'
      end

      def create!(template)
        form_configuration = @instance.form_configurations.where(name: template.name).first_or_initialize
        form_configuration.base_form = template.base_form
        form_configuration.configuration = template.configuration
        form_configuration.return_to = template.return_to
        form_configuration.liquid_body = template.body if template.body.present?
        form_configuration.workflow_steps = WorkflowStep.where(name: template.workflow_steps) if template.workflow_steps.present?
        form_configuration.save!
        template.pages&.each do |slug|
          p = Page.find_by(slug: slug)
          if p.nil?
            logger.warn "Unable to associate #{template.name} with nonexisting page: #{slug}"
          end
        end
      end

      def success_message(template)
        logger.debug "Creating form_configuration: #{template.name}"
      end
    end
  end
end
