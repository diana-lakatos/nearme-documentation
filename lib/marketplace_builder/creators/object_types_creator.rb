# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class ObjectTypesCreator < DataCreator
      include MarketplaceBuilder::CustomAttributesBuilder
      include MarketplaceBuilder::CustomValidatorsBuilder
      include MarketplaceBuilder::FormComponentsBuilder

      def execute!
        data = get_data

        data.keys.each do |key|
          logger.info "Updating #{object_class_name.underscore.humanize.downcase}: #{key.underscore.humanize.titleize}"
          hash = data[key].symbolize_keys

          custom_attributes = hash.delete(:custom_attributes) || []
          custom_validators = hash.delete(:validation) || []
          form_components = hash.delete(:form_components) || []

          hash.each do |key, _value|
            logger.fatal("#{key} is not allowed in #{object_class_name} settings") unless whitelisted_properties.include?(key)
          end

          hash = parse_params(hash)

          object = find_or_create!(hash)
          object.attributes = hash
          object.save!

          update_custom_attributes_for_object(object, custom_attributes) unless custom_attributes.empty?
          update_custom_validators_for_object(object, custom_validators) unless custom_validators.empty?
          update_form_components_for_object(object, form_components) unless form_components.empty?
        end
      end

      def cleanup!
        objects = get_data
        scope = respond_to?(:base_scope) ? base_scope : @instance.send(method_name)
        unused_objects = if objects.empty?
                           scope.all
                         else
                           scope.where('name NOT IN (?)', objects.map { |_key, props| props['name'] })
                         end

        unused_objects.each { |obj| logger.debug "Removing unused #{object_class_name}: #{obj.name}" }
        unused_objects.destroy_all
      end

      protected

      def object_class_name
        raise NotImplementedError
      end

      def find_or_create!(_hash)
        raise NotImplementedError
      end

      def parse_params(hash)
        hash = hash.with_indifferent_access
        hash[:instance_profile_types] = hash[:instance_profile_types].map { |ipt_name| InstanceProfileType.find_by(instance_id: @instance.id, name: ipt_name) } if hash[:instance_profile_types]
        hash[:transactable_types] = hash[:transactable_types].map { |tt_name| TransactableType.find_by(instance_id: @instance.id, name: tt_name) } if hash[:transactable_types]
        hash
      end

      def whitelisted_properties
        [:name]
      end

      private

      def method_name
        object_class_name.pluralize.underscore.to_sym
      end

      def source
        object_class_name.pluralize.underscore
      end
    end
  end
end
