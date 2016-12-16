class InstanceProfileType < ActiveRecord::Base
  include SearchableType

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  SEARCH_VIEWS = %w(list).freeze
  DEPENDENT_CLASS = User

  acts_as_custom_attributes_set
  belongs_to :instance
  belongs_to :default_availability_template, class_name: 'AvailabilityTemplate'
  has_many :custom_attributes_custom_validators, through: :custom_attributes, source: :custom_validators
  has_many :users, through: :user_profiles
  has_many :user_profiles
  has_many :custom_validators, as: :validatable

  has_many :form_components, as: :form_componentable
  has_many :category_linkings, as: :category_linkable, dependent: :destroy
  has_many :categories, through: :category_linkings
  has_many :custom_model_type_linkings, as: :linkable
  has_many :custom_model_types, through: :custom_model_type_linkings

  delegate :translated_bookable_noun, :create_translations!, :translation_namespace, :translation_namespace_was, :translation_key_suffix, :translation_key_suffix_was,
           :translation_key_pluralized_suffix, :translation_key_pluralized_suffix_was, :underscore, to: :translation_manager

  DEFAULT = 'default'.freeze
  SELLER = 'seller'.freeze
  BUYER = 'buyer'.freeze
  PROFILE_TYPES = [DEFAULT, SELLER, BUYER].freeze

  validates :profile_type, inclusion: { in: PROFILE_TYPES }

  scope :default, -> { where(profile_type: DEFAULT) }
  scope :seller, -> { where(profile_type: SELLER) }
  scope :buyer, -> { where(profile_type: BUYER) }
  scope :searchable, -> { where(searchable: true) }
  scope :by_position, -> { order('position ASC') }

  after_create :create_translations!
  after_save :es_users_reindex

  accepts_nested_attributes_for :custom_attributes, update_only: true

  def translation_manager
    @translation_manager ||= InstanceProfileType::InstanceProfileTypeTranslationManager.new(self)
  end

  def available_search_views
    SEARCH_VIEWS
  end

  def default_search_view
    SEARCH_VIEWS.first
  end

  def searcher_type
    'fulltext'
  end

  def show_price_slider
    false
  end

  ['show_date_pickers?', 'display_location_type_filter?'].each do |method|
    define_method(method) { false }
  end

  def to_liquid
    @instance_profile_type_drop ||= InstanceProfileTypeDrop.new(self)
  end

  def has_fields?(profile_type)
    form_components.where(form_type: profile_type).any? { |f| f.form_fields.present? }
  end

  private

  def es_users_reindex
    if admin_approval_changed?
      ElasticIndexerUsersByProfileTypeJob.perform(self.id)
    end
  end
end
