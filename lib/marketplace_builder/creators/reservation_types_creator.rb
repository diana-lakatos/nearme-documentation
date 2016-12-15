# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class ReservationTypesCreator < ObjectTypesCreator
      private

      def object_class_name
        'ReservationType'
      end

      def find_or_create!(hash)
        @instance.reservation_types.where(name: hash[:name]).first_or_create!
      end
    end
  end
end
