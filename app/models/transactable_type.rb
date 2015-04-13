class TransactableType < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  acts_as_custom_attributes_set

  MAX_PRICE = 2147483647
  AVAILABLE_TYPES = ['Listing', 'Buy/Sell']
  BOOKING_TYPES = %w(regular overnight recurring schedule).freeze

  attr_accessor :enable_cancellation_policy

  has_many :transactables, inverse_of: :transactable_type, dependent: :destroy
  has_many :availability_templates, inverse_of: :transactable_type, dependent: :destroy
  has_many :data_uploads, inverse_of: :transactable_type
  has_many :transactable_type_actions
  has_many :action_types, through: :transactable_type_actions
  has_many :form_components, as: :form_componentable
  has_many :rating_systems
  has_many :reviews
  has_many :instance_views
  has_many :categories, as: :categorable

  has_one :schedule, as: :scheduable
  accepts_nested_attributes_for :schedule

  belongs_to :instance

  serialize :pricing_validation, Hash
  serialize :availability_options, Hash
  serialize :custom_csv_fields, Array
  serialize :allowed_countries, Array
  serialize :allowed_currencies, Array

  before_save :normalize_cancellation_policy_enabled, unless: lambda { |transactable_type| transactable_type.buyable }
  after_save :setup_availability_attributes, :if => lambda { |transactable_type| !transactable_type.buyable && transactable_type.availability_options_changed? && transactable_type.availability_options.present? }
  after_update :destroy_translations!, if: lambda { |transactable_type| transactable_type.name_changed? }

  validates_presence_of :name
  validate :min_max_prices_are_correct, unless: lambda { |transactable_type| transactable_type.buyable }
  validate :availability_options_are_correct, unless: lambda { |transactable_type| transactable_type.buyable }
  validates_presence_of :cancellation_policy_hours_for_cancellation, :cancellation_policy_penalty_percentage, if: lambda { |transactable_type| !transactable_type.buyable && transactable_type.enable_cancellation_policy }
  validates_inclusion_of :cancellation_policy_penalty_percentage, in: 0..100, allow_nil: true, message: 'must be between 0 and 100', if: lambda { |transactable_type| !transactable_type.buyable && transactable_type.enable_cancellation_policy }

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

  scope :products, -> { where(buyable: true) }
  scope :services, -> { where(buyable: false) }

  def any_rating_system_active?
    self.rating_systems.any?(&:active)
  end

  def normalize_cancellation_policy_enabled
    if self.enable_cancellation_policy == "1"
      self.cancellation_policy_enabled ||= Time.zone.now
    else
      self.cancellation_policy_enabled = nil
    end
  end

  def defer_availability_rules?
    availability_options && availability_options["defer_availability_rules"]
  end

  def destroy_translations!
    ids = Translation.where('instance_id = ? AND (key like ? OR key like ?)', PlatformContext.current.instance.id, "%.#{self.translation_key_suffix_was}.%", "%.#{self.translation_key_pluralized_suffix_was}.%").inject([]) do |ids_to_delete, t|
      if t.key  =~ /\Asimple_form\.(.+).#{self.translation_key_suffix_was}\.(.+)\z/ || t.key  =~ /\Asimple_form\.(.+).#{self.translation_key_pluralized_suffix_was}\.(.+)\z/
          ids_to_delete << t.id
      end
      ids_to_delete
    end
    Translation.destroy(ids)
    custom_attributes.reload.each(&:create_translations)
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

  def min_max_prices_are_correct
    Transactable::PRICE_TYPES.each do |price|
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

  def setup_availability_attributes
    tta = custom_attributes.where(:name => :confirm_reservations).first.presence || custom_attributes.build(name: :confirm_reservations, internal: true)
    tta.attributes = { attribute_type: "boolean", html_tag: "switch", default_value: availability_options["confirm_reservations"]["default_value"], public: availability_options["confirm_reservations"]["public"], validation_rules: self.class.mandatory_boolean_validation_rules }
    tta.save!
  end

  def self.mandatory_boolean_validation_rules
    { "inclusion" => { "in" => [true, false], "allow_nil" => false } }
  end

  def buy_sell?
    name == 'Buy/Sell'
  end

  def to_liquid
    TransactableTypeDrop.new(self)
  end

  def has_action?(name)
    action_rfq?
  end

  def bookable_noun_plural
    (bookable_noun.presence || name).pluralize
  end

  def wizard_path
    "/transactable_types/#{id}/new"
  end

  def booking_choices
    BOOKING_TYPES.select do |booking_type|
      if booking_type == 'regular'
        %w(hourly daily weekly monthly free).any? { |period| attributes["action_#{period}_booking"] }
      else
        attributes["action_#{booking_type}_booking"]
      end
    end
  end

  BOOKING_TYPES.each do |booking_type|
    define_method("#{booking_type}_booking_enabled?") do
      booking_choices.include?(booking_type)
    end
  end

end

