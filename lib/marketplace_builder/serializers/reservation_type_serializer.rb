module MarketplaceBuilder
  module Serializers
    class ReservationTypeSerializer < BaseSerializer
      resource_name -> (t) { "reservation_types/#{t.name.underscore}" }

      properties :name
      property :transactable_types

      serialize :form_components, using: FormComponentSerializer

      def transactable_types(reservation_type)
        reservation_type.transactable_types.map(&:name)
      end

      def scope
        @model.reservation_types
      end
    end
  end
end
