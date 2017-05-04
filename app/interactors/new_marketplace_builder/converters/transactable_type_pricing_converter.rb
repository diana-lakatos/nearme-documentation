# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class TransactableTypePricingConverter < BaseConverter
      primary_key :order_class_name

      properties :number_of_units, :unit, :min_price_cents, :max_price_cents, :allow_exclusive_price,
                 :allow_book_it_out_discount, :allow_free_booking, :order_class_name, :allow_nil_price_cents,
                 :fixed_price_cents

      def import(data)
      end

      def scope
        @model.pricings
      end
    end
  end
end
