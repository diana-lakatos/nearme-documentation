# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class ReservationTypeConverter < BaseConverter
      primary_key :name
      properties  :name, :withdraw_invitation_when_reject,
        :reverse_immediate_payment, :edit_unconfirmed, :check_overlapping_dates,
        :skip_payment_authorization, :validate_on_adding_to_cart, :step_checkout,
        :require_merchant_account
      property :transactable_types

      convert :validation, using: CustomValidationConverter
      convert :custom_attributes, using: CustomAttributeConverter
      convert :form_components, using: FormComponentConverter

      def scope
        @model.reservation_types
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
