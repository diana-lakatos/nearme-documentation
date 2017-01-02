# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class TransactableTypesCreator < ObjectTypesCreator
      def base_scope
        @instance.transactable_types.where.not(type: 'GroupType')
      end

      private

      def object_class_name
        'TransactableType'
      end

      def whitelisted_properties
        [
          :name,
          :slug,
          :show_path_format,
          :searchable,
          :skip_payment_authorization,
          :hours_for_guest_to_confirm_payment,
          :single_transactable,
          :skip_location,
          :bookable_noun,
          :enable_photo_required,
          :lessor,
          :lessee,
          :enable_reviews,
          :auto_accept_invitation_as_collaborator,
          :require_transactable_during_onboarding,
          :access_restricted_to_invited
        ]
      end

      def find_or_create!(hash)
        @instance.transactable_types.where(name: hash[:name]).first_or_create!
      end
    end
  end
end
