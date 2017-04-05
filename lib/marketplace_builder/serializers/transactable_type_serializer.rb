# frozen_string_literal: true
module MarketplaceBuilder
  module Serializers
    class TransactableTypeSerializer < BaseSerializer
      resource_name ->(t) { "transactable_types/#{t.name.parameterize('_')}" }

      properties :name, :slug, :show_path_format, :searchable, :skip_payment_authorization, :hours_for_guest_to_confirm_payment, :single_transactable,
                 :skip_location, :bookable_noun, :enable_photo_required, :lessor, :lessee, :enable_reviews, :auto_accept_invitation_as_collaborator,
                 :require_transactable_during_onboarding, :access_restricted_to_invited

      serialize :validation, using: CustomValidationSerializer
      serialize :action_types, using: ActionTypeSerializer
      serialize :custom_attributes, using: CustomAttributeSerializer
      serialize :form_components, using: FormComponentSerializer

      def scope
        @model.transactable_types
      end
    end
  end
end
