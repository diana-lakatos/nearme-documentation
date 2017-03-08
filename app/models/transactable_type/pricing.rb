class TransactableType::Pricing < ActiveRecord::Base
  MAX_PRICE = 2_147_483_647
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :action, polymorphic: true, inverse_of: :pricings
  has_many :transactable_pricings, class_name: '::Transactable::Pricing', foreign_key: :transactable_type_pricing_id

  delegate :default_currency, to: :action

  monetize :min_price_cents, allow_nil: true
  monetize :max_price_cents, allow_nil: true
  monetize :fixed_price_cents, allow_nil: true

  before_validation :set_default_order_class

  validates :min_price_cents, :max_price_cents,
            numericality: { greater_than_or_equal_to: 0,
                            less_than_or_equal_to: MAX_PRICE }, allow_blank: true
  validates :min_price_cents,
            numericality: { less_than_or_equal_to: :max_price_for_validation }, allow_blank: true

  validates :number_of_units, numericality: { greater_than: 0 }, presence: true
  validates :unit, presence: true
  validates :order_class_name, presence: true, inclusion: { in: Order::ORDER_TYPES }
  validate :check_pricing_uniqueness

  scope :ordered_by_unit, -> { order('unit DESC, number_of_units ASC') }

  def units_to_s
    [number_of_units, unit].join('_')
  end

  def units_translation(base_key, units_key = 'reservations')
    if units_to_s == '0_free'
      I18n.t('search.pricing_types.free')
    else
      I18n.t(
        base_key,
        no_of_units: number_of_units,
        unit: I18n.t("#{units_key}.#{unit}", count: number_of_units),
        count: number_of_units
      )
    end
  end

  def max_price_for_validation
    max_price_cents.to_i > 0 ? max_price_cents : MAX_PRICE
  end

  def build_transactable_pricing(action_type)
    action_type.pricings.new(
      slice(:number_of_units, :unit).merge(action: action_type,
                                           transactable_type_pricing: self,
                                           price: 0.to_money)
    )
  end

  def set_default_order_class
    self.order_class_name ||= action.try(:related_order_class)
  end

  def order_class_name
    super || action.try(:related_order_class)
  end

  def fixed_price?
    fixed_price_cents && fixed_price_cents > 0
  end

  def subscription?
    action_type == "TransactableType::SubscriptionBooking"
  end

  def to_liquid
    TransactableType::PricingDrop.new(self)
  end

  private

  def check_pricing_uniqueness
    if action && action.pricings.select { |p| p.units_to_s == units_to_s }.many?
      errors.add(:number_of_units, I18n.t('errors.messages.price_type_exists'))
    end
  end
end
