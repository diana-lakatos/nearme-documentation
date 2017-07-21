# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class CustomModelTypeConverter < BaseConverter
      include NewMarketplaceBuilder::CustomAttributesBuilder

      primary_key :name
      properties :name
      property :instance_profile_types
      property :transactable_types
      property :reservation_types
      convert :custom_attributes, using: CustomAttributeConverter

      def scope
        CustomModelType.where(instance_id: @model.id).all
      end

      def instance_profile_types(custom_model)
        custom_model.instance_profile_types.map(&:name)
      end

      def set_instance_profile_types(custom_model, value)
        custom_model.instance_profile_types = Array(value).map { |name| InstanceProfileType.find_by!(instance_id: @model.id, name: name) }
      end

      def reservation_types(custom_model)
        custom_model.reservation_types.map(&:name)
      end

      def set_reservation_types(custom_model, value)
        custom_model.reservation_types = Array(value).map { |name| ReservationType.find_by!(instance_id: @model.id, name: name) }
      end

      def transactable_types(custom_model)
        custom_model.transactable_types.map(&:name)
      end

      def set_transactable_types(custom_model, value)
        custom_model.transactable_types = Array(value).map { |name| TransactableType.find_by!(instance_id: @model.id, name: name) }
      end
    end
  end
end
