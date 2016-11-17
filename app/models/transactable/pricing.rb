# frozen_string_literal: true
class Transactable::Pricing < ActiveRecord::Base
  include OrderValidations
  include Modelable

  belongs_to :action, -> { with_deleted }, polymorphic: true, inverse_of: :pricings, touch: true
  belongs_to :transactable_type_pricing, class_name: '::TransactableType::Pricing'

  attr_accessor :enabled

  inherits_columns_from_association([:unit, :number_of_units], :transactable_type_pricing, :before_validation)

  monetize :price_cents, with_model_currency: :currency, allow_nil: true, subunit_numericality: {
    greater_than_or_equal_to: :min_price,
    less_than_or_equal_to: :max_price,
    if: :monetize_price_cents?
  }
  monetize :exclusive_price_cents, with_model_currency: :currency, allow_nil: true,
                                   subunit_numericality: {
                                     greater_than_or_equal_to: :min_price,
                                     less_than: :max_price,
                                     if: :has_exclusive_price
                                   }

  delegate :allow_book_it_out_discount, :allow_exclusive_price, :allow_nil_price_cents, to: :transactable_type_pricing, allow_nil: true
  delegate :transactable, to: :action, allow_nil: true
  delegate :quantity, to: :transactable, prefix: true

  before_validation :remove_price_if_free

  validates :unit, :number_of_units, :price_cents, presence: true
  validates :number_of_units, numericality: { greater_than: 0 }
  validates :book_it_out_discount, numericality: { in: 1..100 }, if: :has_book_it_out_discount
  validates :book_it_out_minimum_qty, numericality: { greater_than: 0, if: :has_book_it_out_discount }
  validates :book_it_out_minimum_qty, numericality: { less_than: :transactable_quantity,
                                                      message: I18n.t('activerecord.errors.models.transactable.attributes.book_it_out_minimum_qty'), if: :has_book_it_out_discount }
  validate :check_pricing_uniqueness, :check_pricing_definition, unless: :transactable_type_pricing

  scope :by_price, -> { order('price_cents ASC') }
  scope :order_by_unit_and_price, lambda {
    order('COALESCE(is_free_booking, false) DESC, price_cents ASC')
  }
  scope :by_number_and_unit, -> (number, unit) { where(number_of_units: number, unit: unit) }
  scope :by_unit, -> (by_unit) { where(unit: by_unit) if by_unit.present? }

  def order_class
    if transactable_type_pricing
      transactable_type_pricing.order_class_name.constantize
    else
      default_order_class
    end
  end

  def adjusted_number_of_units
    if unit == 'day_month' || unit == 'night_month'
      action.booking_days_per_month
    else
      number_of_units
    end
  end

  def adjusted_unit
    return 'day' if unit == 'day_month'
    return 'night' if unit == 'night_month'
    unit
  end

  def units_and_price
    [adjusted_number_of_units, slice(:price, :id)]
  end

  def units_and_price_cents
    [adjusted_number_of_units, { price: price.cents, id: id }]
  end

  def price_information
    slice(:price, :number_of_units, :unit).merge(availabile_discounts)
  end

  def price_cents_information
    slice(:price_cents, :number_of_units, :unit).merge(availabile_discounts)
  end

  Transactable::ActionType::AVAILABILE_UNITS.each do |u|
    define_method("#{u}_booking?") { unit =~ /^#{u}/ }
  end

  def overnight_booking?
    night_booking?
  end

  def price_per_measurable_unit?
    unit.in? %w(ar hectare)
  end

  # @return [Boolean] whether the "book it out" action is available for this listing
  def book_it_out_available?
    (transactable_type_pricing.nil? || transactable_type_pricing.allow_book_it_out_discount?) && has_book_it_out_discount?
  end

  # @return [Boolean] whether an exclusive price has been defined for this listing
  def exclusive_price_available?
    (transactable_type_pricing.nil? || transactable_type_pricing.allow_exclusive_price?) && has_exclusive_price?
  end

  # @return [Boolean] whether the exclusive price defined for this listing is the only price defined for this listing
  def only_exclusive_price_available?
    exclusive_price_available? && price.to_f.zero?
  end

  def has_price
    !is_free_booking && price_cents.to_i > 0
  end

  def monetize_price_cents?
    !(is_free_or_exclusive? || allow_nil_price_cents)
  end

  def is_free_or_exclusive?
    is_free_booking? || has_exclusive_price? && exclusive_price > 0
  end

  def availabile_discounts
    fields = []
    fields += [:book_it_out_discount, :book_it_out_minimum_qty] if has_book_it_out_discount?
    fields += [:exclusive_price_cents, :exclusive_price] if has_exclusive_price?
    fields.any? ? slice(*fields) : {}
  end

  def price_calculator(order)
    action.try(:price_calculator, order) ||
      (hour_booking? ? Reservation::HourlyPriceCalculator.new(order) : Reservation::DailyPriceCalculator.new(order))
  end

  def all_prices_for_unit
    if day_booking?
      action.prices_by_days
    elsif night_booking?
      action.prices_by_nights
    elsif hour_booking?
      action.prices_by_hours
    end
  end

  def units_to_s
    [number_of_units, unit].join('_')
  end

  def min_price
    transactable_type_pricing.try(:min_price_cents).to_i
  end

  def max_price
    transactable_type_pricing.try(:max_price_cents).to_i > 0 ? transactable_type_pricing.try(:max_price_cents) : TransactableType::Pricing::MAX_PRICE
  end

  def currency
    transactable.try(:currency)
  end

  def remove_price_if_free
    self.price_cents = 0 if is_free_booking
  end

  def jsonapi_serializer_class_name
    'PricingJsonSerializer'
  end

  def to_liquid
    @pricing_drop ||= Transactable::PricingDrop.new(self)
  end

  private

  def check_pricing_uniqueness
    if action.pricings.select { |p| p.units_to_s == units_to_s }.many?
      errors.add(:number_of_units, I18n.t('errors.messages.price_type_exists'))
    end
  end

  def check_pricing_definition
    if action && action.transactable_type_action_type.pricings.find { |p| p.units_to_s == units_to_s }
      errors.add(:number_of_units, I18n.t('errors.messages.price_defined'))
    end
  end

  def default_order_class
    case action.type
    when 'Transactable::SubscriptionBooking'
      RecurringBooking
    when 'Transactable::PurchaseAction'
      Purchase
    else
      if action.transactable_type_action_type.transactable_type.try(:skip_payment_authorization?)
        DelayedReservation
      else
        Reservation
      end
    end
  end
end
