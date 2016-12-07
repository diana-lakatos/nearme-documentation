# frozen_string_literal: true
require 'utils/form_components_creator'

module MarketplaceBuilder
  module Creators
    class FormComponentsCreator < DataCreator
      def execute!
        data = get_data
        return if data.empty?

        MarketplaceBuilder::Logger.log "#{object_class_name} form components"

        data.keys.each do |name|
          MarketplaceBuilder::Logger.log "\t#{name}:"
          object = @instance.send(method_name).where(name: name).first

          MarketplaceBuilder::Logger.log "\t  Cleanup..."
          object.form_components.destroy_all
          create_form_components_for_object(object, data[name])
        end
      end

      protected

      def object_class_name
        raise NotImplementedError
      end

      private

      def method_name
        object_class_name.pluralize.underscore.to_sym
      end

      def file_name
        "#{object_class_name.pluralize.underscore}.yml"
      end

      def source
        File.join('custom_attributes', file_name)
      end

      def create_form_components_for_object(object, component_types)
        component_types.each do |type, components|
          MarketplaceBuilder::Logger.log "\t  Creating #{type}..."
          creator = Utils::BaseComponentCreator.new(object)
          creator.instance_variable_set(:@form_type_class, "FormComponent::#{type}".safe_constantize)
          components.map!(&:symbolize_keys)
          creator.create_components!(components)
        end
      end
    end
  end
end
