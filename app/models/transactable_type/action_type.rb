class TransactableType::ActionType < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  AVAILABILE_UNITS = %w(day hour night event subscription_day subscription_month allow_free item).freeze

  belongs_to :instance
  belongs_to :transactable_type
  has_many :reservations
  has_many :pricings, as: :action, inverse_of: :action
  has_many :transactable_action_types, class_name: 'Transactable::ActionType', foreign_key: :transactable_type_action_type_id

  delegate :default_currency, :hide_location_availability?, to: :transactable_type

  validates_presence_of :cancellation_policy_hours_for_cancellation,
    :cancellation_policy_penalty_percentage,
      if: :cancellation_policy_enabled
  validates_inclusion_of :cancellation_policy_penalty_percentage,
    in: 0..100, allow_nil: true,
      message: 'must be between 0 and 100', if: :cancellation_policy_enabled

  validates_numericality_of :hours_to_expiration, :minimum_booking_minutes,
    :cancellation_policy_hours_for_cancellation, :cancellation_policy_penalty_percentage,
      :cancellation_policy_penalty_hours, greater_than_or_equal_to: 0, allow_nil: true

  accepts_nested_attributes_for :pricings, allow_destroy: true, reject_if: lambda { |attrs| attrs[:number_of_units].blank? && attrs[:unit].blank? }

  scope :bookable, -> { where.not(type: 'TransactableType::NoActionBooking')}
  scope :enabled, -> { where(enabled: true) }

  AVAILABILE_UNITS.each do |u|
    define_method("#{u}_booking?"){ pricings.any?(&:"#{u}_booking?".to_sym) }
  end

  AVAILABILE_UNITS.each do |u|
    define_method("#{u}_pricings"){ pricings.select(&:"#{u}_booking?") }
  end

  def is_no_action?
    false
  end

  def pricing_for(units)
    pricings.find{|p| p.units_to_s == units }
  end

  def cancellation_policy_enabled=(val)
    if val == "1"
      self[:cancellation_policy_enabled] ||= Time.zone.now
    else
      self[:cancellation_policy_enabled] = nil
    end
  end

  def name
    self.class.name.demodulize.underscore
  end

  def can_be_free?
    true
  end

  def related_order_class
    if transactable_type.try(:skip_payment_authorization?)
      'DelayedReservation'
    else
      'Reservation'
    end
  end

end