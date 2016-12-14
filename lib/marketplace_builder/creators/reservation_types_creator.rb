# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class ReservationTypesCreator < ObjectTypesCreator
      private

      def object_class_name
        return "ReservationType"
      end
    end
  end
end
