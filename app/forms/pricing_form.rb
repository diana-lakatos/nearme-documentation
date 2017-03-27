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

  def price=(value)
    model.price = value
    self.price_cents = model.price.fractional
  end

  def price
    model.price
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
