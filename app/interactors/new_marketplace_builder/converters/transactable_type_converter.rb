# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class TransactableTypeConverter < BaseConverter
      primary_key :name
      properties :name, :slug, :show_path_format, :searchable, :skip_payment_authorization, :hours_for_guest_to_confirm_payment,
                 :single_transactable, :skip_location, :bookable_noun, :enable_photo_required, :lessor, :lessee, :enable_reviews,
                 :auto_accept_invitation_as_collaborator, :require_transactable_during_onboarding, :access_restricted_to_invited

      convert :validation, using: CustomValidationConverter
      convert :action_types, using: ActionTypeConverter
      convert :custom_attributes, using: CustomAttributeConverter
      convert :form_components, using: FormComponentConverter

      def scope
        @model.transactable_types
      end
    end
  end
end
