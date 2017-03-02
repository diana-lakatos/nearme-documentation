# frozen_string_literal: true
class TransactableType < ActiveRecord::Base
  include SearchableType

  self.inheritance_column = :type
  default_scope { where("transactable_types.type !='Spree::ProductType' or transactable_types.type is NULL") }
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_custom_attributes_set

  DEPENDENT_CLASS = Transactable
  AVAILABLE_TYPES = ['Listing'].freeze
  AVAILABLE_ACTION_TYPES = [NoActionBooking, SubscriptionBooking, EventBooking, TimeBasedBooking, PurchaseAction, OfferAction].freeze
  SEARCH_VIEWS = %w(mixed list listing_mixed).freeze
  AVAILABLE_SHOW_PATH_FORMATS = [
    '/transactable_types/:transactable_type_id/locations/:location_id/listings/:id',
    '/:transactable_type_id/locations/:location_id/listings/:id',
    '/:transactable_type_id/:location_id/listings/:id',
    '/locations/:location_id/:id',
    '/locations/:location_id/listings/:id',
    '/:transactable_type_id/:id',
    '/listings/:id'
  ].freeze

  INTERNAL_FIELDS = [
    :name, :description, :capacity, :quantity, :confirm_reservations,
    :last_request_photos_sent_at, :capacity
  ].freeze

  has_many :action_types, -> { enabled }, dependent: :destroy
  has_many :all_action_types, dependent: :destroy, class_name: 'TransactableType::ActionType'

  has_many :custom_attributes_custom_validators, -> { where.not(custom_attributes: { attribute_type: %w(photo file) }) }, through: :custom_attributes, source: :custom_validators
  has_one :event_booking
  has_one :time_based_booking
  has_one :subscription_booking
  has_one :no_action_booking
  has_one :purchase_action
  has_one :offer_action

  has_many :form_components, as: :form_componentable, dependent: :destroy
  has_many :data_uploads, as: :importable, dependent: :destroy
  has_many :rating_systems, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :category_linkings, as: :category_linkable, dependent: :destroy
  has_many :categories, through: :category_linkings
  has_many :custom_model_type_linkings, as: :linkable
  has_many :custom_model_types, through: :custom_model_type_linkings
  has_many :custom_validators, as: :validatable
  has_many :additional_charge_types, foreign_type: :charge_type_target_type, foreign_key: :charge_type_target_id
  has_many :merchant_fees, foreign_type: :charge_type_target_type, foreign_key: :charge_type_target_id, as: :charge_type_target
  has_many :transactable_type_instance_views, dependent: :destroy
  has_many :instance_views, through: :transactable_type_instance_views
  has_many :transactables, dependent: :destroy, foreign_key: 'transactable_type_id'
  has_many :availability_templates, dependent: :destroy, foreign_key: 'transactable_type_id'
  belongs_to :default_availability_template, class_name: 'AvailabilityTemplate'

  belongs_to :instance
  belongs_to :reservation_type

  serialize :custom_csv_fields, Array
  serialize :allowed_currencies, Array
  serialize :availability_options, Hash

  after_update :destroy_translations!, if: ->(transactable_type) { transactable_type.name_changed? || transactable_type.bookable_noun_changed? || transactable_type.lessor_changed? || transactable_type.lessee_changed? }
  before_validation :set_default_options
  after_create :create_translations!
  after_create :create_reservation_type!

  scope :searchable, -> { where(searchable: true) }
  scope :by_position, -> { order('position ASC') }
  scope :order_by_array_of_names, lambda { |names|
    names_decorated = names.each_with_index.map { |tt, i| "WHEN transactable_types.name='#{tt}' THEN #{i}" }
    order("CASE #{names_decorated.join(' ')} END") if names.present?
  }
  scope :found_and_sorted_by_names, ->(names) { where(name: names).order_by_array_of_names(names) }

  validates :name, :default_search_view, :searcher_type, presence: true
  validates :category_search_type, presence: true, if: ->(transactable_type) { transactable_type.show_categories }
  validates :show_path_format, inclusion: { in: AVAILABLE_SHOW_PATH_FORMATS, allow_nil: true }
  validates_associated :action_types

  accepts_nested_attributes_for :custom_attributes, update_only: true
  accepts_nested_attributes_for :rating_systems, update_only: true
  accepts_nested_attributes_for :availability_templates
  accepts_nested_attributes_for :action_types
  accepts_nested_attributes_for :all_action_types
  accepts_nested_attributes_for :merchant_fees, allow_destroy: true

  delegate :translated_bookable_noun, :translation_namespace, :translation_namespace_was, :translation_key_suffix, :translation_key_suffix_was,
           :translation_key_pluralized_suffix, :translation_key_pluralized_suffix_was, :underscore, to: :translation_manager

  validate do
    if type == 'TransactableType' && !(all_action_types.any?(&:enabled) || action_types.any?(&:enabled))
      errors.add(:base, I18n.t('errors.messages.transactable_type_actions_blank'))
    end
  end

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :scoped], scope: :instance
  def slug_candidates
    [
      :name,
      [:name, self.class.last.try(:id).to_i + 1],
      [:name, rand(1_000_000)]
    ]
  end

  scope :with_parameterized_name, -> (name) { where(parameterized_name: parameterize_name(name)).limit(1) }
  before_save :generate_parameterized_name, if: -> (transactable_type){ transactable_type.name_changed? }
  class << self
    def parameterize_name(name)
      name.to_s.downcase.tr(' ', '_')
    end
  end

  def generate_parameterized_name
    self.parameterized_name = self.class.parameterize_name(name)
  end

  def any_rating_system_active?
    rating_systems.any?(&:active)
  end

  def allowed_currencies
    super || instance.allowed_currencies
  end

  def allowed_currencies=(currencies)
    currencies.reject!(&:blank?)
    super(currencies)
  end

  def default_currency
    super.presence || instance&.default_currency || PlatformContext.current.instance.default_currency
  end

  def translated_lessor(count = 1)
    translation_manager.find_key_with_count('lessor', count)
  end

  def translated_lessee(count = 1)
    translation_manager.find_key_with_count('lessee', count)
  end

  delegate :create_translations!, to: :translation_manager

  def create_reservation_type!
    return true if reservation_type.present?

    reservation_type = ReservationType.create!(name: "#{name} checkout",
                                               transactable_types: [self],
                                               settings: {
                                                 'skip_payment_authorization' => 'false',
                                                 'validate_on_adding_to_cart' => 'true'
                                               },
                                               step_checkout: false)
    Utils::FormComponentsCreator.new(reservation_type).create!
  end

  def destroy_translations!
    translation_manager.try(:destroy_translations!)
  end

  def self.mandatory_boolean_validation_rules
    { 'inclusion' => { 'in' => [true, false], 'allow_nil' => false } }
  end

  def translation_manager
    @translation_manager ||= TransactableType::TransactableTypeTranslationManager.new(self)
  end

  def to_liquid
    @transactable_type_drop ||= TransactableTypeDrop.new(self)
  end

  def has_action?(_name)
    action_rfq?
  end

  def create_rating_systems
    RatingConstants::RATING_SYSTEM_SUBJECTS.each do |subject|
      rating_system = rating_systems.create!(subject: subject)
      RatingConstants::VALID_VALUES.each { |value| rating_system.rating_hints.create!(value: value) }
    end
  end

  def category_search_type=(cat_search_type)
    super(cat_search_type.presence || 'AND')
  end

  def and_category_search?
    category_search_type == 'AND'
  end

  def or_category_search?
    category_search_type == 'OR'
  end

  def date_pickers_relative_mode?
    date_pickers_mode == 'relative'
  end

  def signature
    [id, 'TransactableType'].join(',')
  end

  def available_search_views
    SEARCH_VIEWS
  end

  def wizard_path(options = {})
    Rails.application.routes.url_helpers.transactable_type_space_wizard_list_path(self, options)
  end

  def hide_location_availability?
    skip_location?
  end

  def initialize_action_types
    AVAILABLE_ACTION_TYPES.each do |action_type_class|
      action = action_type_class.where(transactable_type: self).first_or_initialize do |at|
        at.enabled = false
      end
      action.pricings.first_or_initialize
      association(:all_action_types).add_to_target(action)
    end
  end

  def required_custom_attributes
    custom_attributes.required
  end

  def required_custom_attributes_for_csv(import_model = 'transactable')
    required_custom_attributes.map { |required_attribute| { import_model => required_attribute.name } }
  end

  private

  def set_default_options
    self.default_search_view ||= available_search_views.first
    self.search_engine ||= 'elasticsearch'
    self.searcher_type ||= 'geo'
  end
end
