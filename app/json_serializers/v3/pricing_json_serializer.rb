class V3::PricingJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :number_of_units
  attribute :unit
  attribute :units_to_s
  attribute :price_cents
  attribute :has_exclusive_price
  attribute :exclusive_price_cents
  attribute :has_book_it_out_discount
  attribute :book_it_out_discount
  attribute :book_it_out_minimum_qty
  attribute :is_free_booking

end
