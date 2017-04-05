# frozen_string_literal: true
class PricingForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  property :transactable_type_pricing_id
  property :enabled
  property :is_free_booking
  property :price_cents
  property :price, virtual: true
  property :unit
  property :number_of_units
  property :has_exclusive_price
  property :exclusive_price
  property :book_it_out_minimum_qty
  property :has_book_it_out_discount
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
        configuration.each do |field, options|
          property :"#{field}", options[:property_options].presence || {}
          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end
  end
end
