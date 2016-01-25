class TransactableType < ActiveRecord::Base
  self.inheritance_column = :type
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_custom_attributes_set

  AVAILABLE_TYPES = ['Listing', 'Buy/Sell']

  INTERNAL_FIELDS = [
    :name, :description, :capacity, :quantity, :confirm_reservations,
    :last_request_photos_sent_at, :capacity
  ]

  has_many :form_components, as: :form_componentable
  has_many :data_uploads, as: :importable, dependent: :destroy
  has_many :rating_systems
  has_many :reviews
  has_many :instance_views
  has_many :category_linkings, as: :category_linkable, dependent: :destroy
  has_many :categories, through: :category_linkings
  has_many :custom_validators, as: :validatable
  has_many :additional_charge_types, as: :additional_charge_type_target
  has_many :transactable_type_instance_views, dependent: :destroy
  has_many :instance_views, through: :transactable_type_instance_views

  belongs_to :instance

  serialize :custom_csv_fields, Array
  serialize :allowed_currencies, Array
  serialize :availability_options, Hash

  after_update :destroy_translations!, if: lambda { |transactable_type| transactable_type.name_changed? || transactable_type.bookable_noun_changed? || transactable_type.lessor_changed? || transactable_type.lessee_changed? }
  before_validation :set_default_options
  after_create :create_translations!

  scope :products, -> { where(type: 'Spree::ProductType') }
  scope :services, -> { where(type: 'ServiceType') }
  scope :searchable, -> { where(searchable: true) }
  scope :by_position, -> { order('position ASC') }
  scope :order_by_array_of_names, -> (names) {
    names_decorated = names.each_with_index.map {|tt, i| "WHEN transactable_types.name='#{tt}' THEN #{i}" }
    order("CASE #{names_decorated.join(' ')} END") if names.present?
  }
  scope :found_and_sorted_by_names, -> (names) { where(name: names).order_by_array_of_names(names) }

  validates :name, :default_search_view, :searcher_type, presence: true
  validates :category_search_type, presence: true, if: -> (transactable_type){ transactable_type.show_categories }

  accepts_nested_attributes_for :custom_attributes, update_only: true

  delegate :translated_bookable_noun, :translation_namespace, :translation_namespace_was, :translation_key_suffix, :translation_key_suffix_was,
    :translation_key_pluralized_suffix, :translation_key_pluralized_suffix_was, :underscore, to: :translation_manager

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :scoped], scope: :instance
  def slug_candidates
    [
      :name,
      ([:name, I18n.l(Date.current, format: :long)] rescue [:name, Date.current.to_s])
    ]
  end

  def any_rating_system_active?
    self.rating_systems.any?(&:active)
  end

  def allowed_currencies
    super || instance.allowed_currencies
  end

  def allowed_currencies=currencies
    currencies.reject!(&:blank?)
    super(currencies)
  end

  def default_currency
    super.presence || instance.default_currency
  end

  def translated_lessor(count = 1)
    translation_manager.find_key_with_count('lessor', count)
  end

  def translated_lessee(count = 1)
    translation_manager.find_key_with_count('lessee', count)
  end

  def create_translations!
    translation_manager.create_translations!
  end

  def destroy_translations!
    translation_manager.destroy_translations!
  end

  def self.mandatory_boolean_validation_rules
    { "inclusion" => { "in" => [true, false], "allow_nil" => false } }
  end

  def translation_manager
    @translation_manager ||= TransactableType::TransactableTypeTranslationManager.new(self)
  end

  def to_liquid
    raise NotImplementedError.new('Abstract method')
  end

  def has_action?(name)
    action_rfq?
  end

  def create_rating_systems
    RatingConstants::RATING_SYSTEM_SUBJECTS.each do |subject|
      rating_system = self.rating_systems.create!(subject: subject)
      RatingConstants::VALID_VALUES.each { |value| rating_system.rating_hints.create!(value: value) }
    end
  end

  def category_search_type=(cat_search_type)
    super(cat_search_type.presence || 'AND')
  end

  def and_category_search?
    category_search_type == "AND"
  end

  def or_category_search?
    category_search_type == "OR"
  end

  def date_pickers_relative_mode?
    date_pickers_mode == 'relative'
  end

  def signature
    [id, type].join(",")
  end

  private

  def set_default_options
    self.default_search_view ||=  available_search_views.first
    self.search_engine ||= Instance::SEARCH_ENGINES.first
  end

end

