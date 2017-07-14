# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class FormConfigurationConverter < BaseConverter
      primary_key :name
      properties :name, :base_form, :configuration
      property :body

      %i(workflow_steps authorization_policies email_notifications
         sms_notifications api_call_notifications).each do |property_name|

        send(:property, property_name)

        define_method(:"#{property_name}") do |form_configuration|
          form_configuration.send(property_name).pluck(:name)
        end

        define_method(:"set_#{property_name}") do |form_configuration, names|
          form_configuration.send(property_name).pluck(:name)

          singularized_property_name = property_name.to_s.singularize
          form_configuration.send(:"#{singularized_property_name}_ids=",
                                  singularized_property_name.camelize.constantize.where(name: names).pluck(:id))
        end
      end

      def body(form_configuration)
        form_configuration.liquid_body
      end

      def set_body(form_configuration, value)
        form_configuration.liquid_body = value
      end

      def scope
        FormConfiguration.where(instance_id: @model.id)
      end
    end
  end
end
