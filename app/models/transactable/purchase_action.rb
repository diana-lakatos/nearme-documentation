class Transactable::PurchaseAction < Transactable::ActionType
  has_one :pricing, as: :action
  delegate :price, :unit, to: :pricing, allow_nil: true

  validates :pricings, presence: true, if: :enabled?
  validates_associated :pricings, if: :enabled?

  def bookable?
    quantity > 0
  end

  def booking_module_options
    super.merge({
      fixed_price_cents: pricing.price_cents,
    })
  end

 def validate_all_dates_available
    if invalid_dates.any?
      order.errors.add(:base, I18n.t('reservations_review.errors.dates_not_available', dates: invalid_dates.map(&:as_formatted_string).join(', ')))
    end
  end


end
