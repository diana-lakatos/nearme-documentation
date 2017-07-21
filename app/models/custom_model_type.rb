# frozen_string_literal: true
class CustomModelType < ActiveRecord::Base
  include WithParameterizedName
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  acts_as_custom_attributes_set

  delegate :translated_bookable_noun, :create_translations!, :translation_namespace, :translation_namespace_was, :translation_key_suffix, :translation_key_suffix_was,
           :translation_key_pluralized_suffix, :translation_key_pluralized_suffix_was, :underscore, :destroy_translations!, to: :translation_manager

  belongs_to :instance
  has_many :customizations, dependent: :destroy, inverse_of: :custom_model_type
  has_many :custom_model_type_linkings, dependent: :destroy
  has_many :transactable_types, through: :custom_model_type_linkings
  has_many :reservation_types, through: :custom_model_type_linkings
  has_many :project_types, through: :custom_model_type_linkings
  has_many :offer_types, through: :custom_model_type_linkings
  has_many :instance_profile_types, through: :custom_model_type_linkings
  has_many :custom_attributes_custom_validators, -> { where.not(custom_attributes: { attribute_type: %w(photo file) }) }, through: :custom_attributes, source: :custom_validators
  has_many :custom_validators, as: :validatable

  after_update :destroy_translations!, if: ->(model_type) { model_type.name_changed? }
  after_create :create_translations!

  validates :name, uniqueness: { scope: [:instance_id, :deleted_at] }

  scope :transactables, -> { joins(:custom_model_type_linkings).where(custom_model_type_linkings: { linkable_type: 'TransactableType' }) }
  scope :users,         -> { joins(:custom_model_type_linkings).where(custom_model_type_linkings: { linkable: PlatformContext.current.instance.default_profile_type }) }
  scope :sellers,       -> { joins(:custom_model_type_linkings).where(custom_model_type_linkings: { linkable: PlatformContext.current.instance.seller_profile_type }) }
  scope :buyers,        -> { joins(:custom_model_type_linkings).where(custom_model_type_linkings: { linkable: PlatformContext.current.instance.buyer_profile_type }) }
  scope :user_profiles, -> { joins(:custom_model_type_linkings).where(custom_model_type_linkings: { linkable_type: 'InstanceProfileType' }) }

  def translation_manager
    @translation_manager ||= CustomModelType::CustomModelTypeTranslationManager.new(self)
  end

  def to_liquid
    @custom_model_drop ||= CustomModelTypeDrop.new(self)
  end
end
