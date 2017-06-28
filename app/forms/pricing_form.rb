# frozen_string_literal: true
class PricingForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections

  # @!attribute transactable_type_pricing_id
  #   @return [Integer] numeric identifier of the associated TransactableType::Pricing
  property :transactable_type_pricing_id

  # @!attribute enabled
  #   @return [Boolean] whether this pricing is enabled
  property :enabled

  # @!attribute is_free_booking
  #   @return [Boolean] whether the pricing represents an item that can be acquired for free
  property :is_free_booking

  # @!attribute price_cents
  #   @return [Integer] price in cents associated with the pricing
  property :price_cents

  # @!attribute price
  #   @return [Money] price associated with the pricing
  property :price, virtual: true

  # @!attribute unit
  #   @return [String] unit associated with the pricing e.g. item, night, night_month, day,
  #     subscription_day, day_month, event, subscription_month, hour
  property :unit

  # @!attribute number_of_units
  #   @return [Integer] number of units defined for this particular pricing
  property :number_of_units

  # @!attribute has_exclusive_price
  #   @return [Boolean] whether an exclusive price has been defined for this pricing object
  property :has_exclusive_price

  # @!attribute exclusive_price
  #   @return [Boolean] the actual exclusive price defined for this pricing object
  property :exclusive_price

  # @!attribute book_it_out_minimum_qty
  #   @return [Integer] minimum quantity for which the "book it out" discount applies
  property :book_it_out_minimum_qty

  # @!attribute has_book_it_out_discount
  #   @return [Boolean] whether a "book it out" discount is enabled for this pricing
  property :has_book_it_out_discount

  # @!attribute book_it_out_discount
  #   @return [Integer] the actual "book it out" discount (if available) defined
  #     for this pricing
  property :book_it_out_discount

  property :_destroy, virtual: true

  validates :price, presence: true

  def price=(value)
    old_value = model.price
    model.price = value
    super(model.price.to_f)
    self.price_cents = model.price.fractional
    model.price = old_value
  end

  def price
    super.presence || model.price
  end

  class << self
    def decorate(configuration)
      Class.new(self) do
        inject_dynamic_fields(configuration, whitelisted: [:id, :transactable_type_pricing_id, :price, :price_cents, :number_of_units, :unit, :has_exclusive_price, :exclusive_price, :has_book_it_out_discount, :book_it_out_discount, :book_it_out_minimum_qty, :enabled, :is_free_booking, :currency])
      end
    end
  end
end
