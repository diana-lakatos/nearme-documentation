module MarketplaceBuilder
  module Serializers
    class TransactableTypePricingSerializer < BaseSerializer
      properties :number_of_units, :unit, :min_price_cents, :max_price_cents, :allow_exclusive_price, :allow_book_it_out_discount, :allow_free_booking,
        :order_class_name, :allow_nil_price_cents, :fixed_price_cents

      def scope
        @model.pricings
      end
    end
  end
end
