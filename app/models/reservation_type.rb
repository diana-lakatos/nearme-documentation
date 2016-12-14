# frozen_string_literal: true
class ReservationType < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_custom_attributes_set

  belongs_to :instance
  has_many :transactable_types
  has_many :form_components, as: :form_componentable
  has_many :custom_validators, as: :validatable

  has_many :custom_attributes_custom_validators, through: :custom_attributes, source: :custom_validators
  has_many :category_linkings, as: :category_linkable, dependent: :destroy
  has_many :categories, through: :category_linkings

  has_many :custom_model_type_linkings, as: :linkable
  has_many :custom_model_types, through: :custom_model_type_linkings

  delegate :translated_bookable_noun, :create_translations!, :translation_namespace,
           :translation_namespace_was, :translation_key_suffix, :translation_key_suffix_was,
           :translation_key_pluralized_suffix, :translation_key_pluralized_suffix_was, :underscore, to: :translation_manager

  validates :name, :transactable_types, presence: true

  store_accessor :settings, :address_in_radius, :validate_on_adding_to_cart, :skip_payment_authorization, :check_overlapping_dates,
                 :edit_unconfirmed

  def translation_manager
    @translation_manager ||= InstanceProfileType::InstanceProfileTypeTranslationManager.new(self)
  end

  def validate_on_adding_to_cart
    super == 'true'
  end
  alias validate_on_adding_to_cart? validate_on_adding_to_cart

  def skip_payment_authorization
    super == 'true'
  end
  alias skip_payment_authorization? skip_payment_authorization

  def check_overlapping_dates
    super == 'true'
  end

  def edit_unconfirmed
    super == 'true'
  end
end
