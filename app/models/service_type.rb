class ServiceType < TransactableType
  acts_as_paranoid

  MAX_PRICE = 2147483647
  BOOKING_TYPES = %w(regular overnight schedule subscription recurring).freeze
  SEARCH_VIEWS = %w(mixed list listing_mixed)

  attr_accessor :enable_cancellation_policy

  has_many :transactables, dependent: :destroy, foreign_key: 'transactable_type_id'
  has_many :availability_templates, dependent: :destroy, foreign_key: 'transactable_type_id'
  belongs_to :default_availability_template, class_name: 'AvailabilityTemplate'

  has_one :schedule, as: :scheduable, dependent: :destroy
  accepts_nested_attributes_for :schedule

  serialize :pricing_validation, Hash
  serialize :availability_options, Hash

  before_save :normalize_cancellation_policy_enabled

  validates_numericality_of :hours_to_expiration, :minimum_booking_minutes, :cancellation_policy_hours_for_cancellation,
    :cancellation_policy_penalty_percentage, greater_than_or_equal_to: 0
  validate :min_max_prices_are_correct
  validate :availability_options_are_correct
  validate :check_booking_options
  validates_presence_of :cancellation_policy_hours_for_cancellation, :cancellation_policy_penalty_percentage, if: lambda { |transactable_type| transactable_type.enable_cancellation_policy }
  validates_inclusion_of :cancellation_policy_penalty_percentage, in: 0..100, allow_nil: true, message: 'must be between 0 and 100', if: lambda { |transactable_type| transactable_type.enable_cancellation_policy }

  accepts_nested_attributes_for :availability_templates

  monetize :min_daily_price_cents, allow_nil: true
  monetize :max_daily_price_cents, allow_nil: true
  monetize :min_hourly_price_cents, allow_nil: true
  monetize :max_hourly_price_cents, allow_nil: true
  monetize :min_weekly_price_cents, allow_nil: true
  monetize :max_weekly_price_cents, allow_nil: true
  monetize :min_monthly_price_cents, allow_nil: true
  monetize :max_monthly_price_cents, allow_nil: true
  monetize :min_fixed_price_cents, allow_nil: true
  monetize :max_fixed_price_cents, allow_nil: true

  def normalize_cancellation_policy_enabled
    if self.enable_cancellation_policy == "1"
      self.cancellation_policy_enabled ||= Time.zone.now
    else
      self.cancellation_policy_enabled = nil
    end
  end

  def daily_options_names
    pricing_options = []
    pricing_options << "daily" if action_daily_booking
    pricing_options << "weekly" if action_weekly_booking
    pricing_options << "monthly" if action_monthly_booking
    pricing_options
  end

  def pricing_options_long_period_names
    pricing_options = []
    pricing_options << "hourly" if action_hourly_booking
    pricing_options << "daily" if action_daily_booking
    pricing_options << "weekly" if action_weekly_booking
    pricing_options << "monthly" if action_monthly_booking
    pricing_options
  end

  def subscription_options_names
    pricing_options = []
    pricing_options << "weekly_subscription" if action_weekly_subscription_booking
    pricing_options << "monthly_subscription" if action_monthly_subscription_booking
    pricing_options
  end

  def available_price_types
    Transactable::PRICE_TYPES.select{ |price| self.try("action_#{price}_booking") }
  end

  def min_max_prices_are_correct
    Transactable::PRICE_TYPES.each do |price|
      next unless respond_to?(:"min_#{price}_price_cents") || respond_to?(:"max_#{price}_price_cents")
      if self.send(:"min_#{price}_price_cents").present? && self.send(:"max_#{price}_price_cents").present?
        errors.add(:"min_#{price}_price_cents", "min can't be greater than max") if self.send(:"min_#{price}_price_cents").to_i > self.send(:"max_#{price}_price_cents").to_i
      end
      errors.add(:"min_#{price}_price_cents", "min can't be lower than zero") if self.send(:"min_#{price}_price_cents").to_i < 0
      errors.add(:"max_#{price}_price_cents", "max can't be greater than #{MAX_PRICE}") if self.send(:"max_#{price}_price_cents").to_i > MAX_PRICE
    end
  end

  def availability_options_are_correct
    errors.add("availability_options[confirm_reservations][public]", "must be set") if availability_options["confirm_reservations"]["public"].nil?
    errors.add("availability_options[confirm_reservations][default_value]", "must be set") if availability_options["confirm_reservations"]["default_value"].nil?
  rescue
    errors.add("availability_options[confirm_reservations][public]", "must be set")
    errors.add("availability_options[confirm_reservations][default_value]", "must be set")
  end

  def check_booking_options
    if booking_choices.empty?
      errors.add(:action_regular_booking, "at least one option must be checked")
      errors.add(:action_overnight_booking, "at least one option must be checked")
      errors.add(:action_schedule_booking, "at least one option must be checked")
    end
  end

  def to_liquid
    @service_type_drop ||= ServiceTypeDrop.new(self)
  end

  def wizard_path
    "/transactable_types/#{id}/new"
  end

  def booking_choices
    BOOKING_TYPES.select do |booking_type|
      try("action_#{booking_type}_booking")
    end
  end

  def action_subscription_booking
    action_monthly_subscription_booking || action_weekly_subscription_booking
  end

  BOOKING_TYPES.each do |booking_type|
    define_method("#{booking_type}_booking_enabled?") do
      booking_choices.include?(booking_type)
    end
  end

  def buyable?
    false
  end

  def hide_location_availability
    skip_location? || !availability_options["defer_availability_rules"]
  end

  def available_search_views
    SEARCH_VIEWS
  end

  private

  def set_default_options
    super
    self.searcher_type ||= 'geo'
  end

end

