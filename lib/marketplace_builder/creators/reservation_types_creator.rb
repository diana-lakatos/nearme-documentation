# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class ReservationTypesCreator < ObjectTypesCreator
      private

      def object_class_name
        'ReservationType'
      end

      def find_or_create!(hash)
        @instance.reservation_types.where(name: hash[:name]).first_or_initialize
      end

      def whitelisted_properties
        [:name, :withdraw_invitation_when_reject, :transactable_types, :reverse_immediate_payment]
      end

    end
  end
end
