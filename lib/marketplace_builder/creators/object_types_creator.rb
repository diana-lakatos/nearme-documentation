# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class ObjectTypesCreator < DataCreator
      include MarketplaceBuilder::CustomAttributesBuilder
      include MarketplaceBuilder::CustomValidatorsBuilder
      include MarketplaceBuilder::FormComponentsBuilder

      def execute!
        MarketplaceBuilder::Logger.info object_class_name.pluralize.underscore.humanize.titleize.to_s

        data = get_data
        cleanup!(data) if @mode == MarketplaceBuilder::MODE_REPLACE

        data.keys.each do |key|
          MarketplaceBuilder::Logger.log "\t#{key.underscore.humanize.titleize}:"
          hash = data[key].symbolize_keys

          custom_attributes = hash.delete(:custom_attributes) || []
          custom_validators = hash.delete(:custom_validators) || []
          form_components = hash.delete(:form_components) || []

          hash.each do |key, _value|
            raise MarketplaceBuilder::Error, "#{key} is not allowed in #{object_class_name} settings" unless whitelisted_properties.include?(key)
          end

          object = @instance.send(method_name).where(hash).first_or_create!

          update_custom_attributes_for_object(object, custom_attributes) unless custom_attributes.empty?
          update_custom_validators_for_object(object, custom_validators) unless custom_validators.empty?
          update_form_comopnents_for_object(object, form_components) unless form_components.empty?
        end
      end

      protected

      def object_class_name
        raise NotImplementedError
      end

      def whitelisted_properties
        [:name]
      end

      private

      def cleanup!(data)
        used_objects = data.map do |_key, props|
          props['name']
        end

        @instance.send(method_name).where('name NOT IN (?)', used_objects).destroy_all
      end

      def method_name
        object_class_name.pluralize.underscore.to_sym
      end

      def source
        object_class_name.pluralize.underscore
      end
    end
  end
end
