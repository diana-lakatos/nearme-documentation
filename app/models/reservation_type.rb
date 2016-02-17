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
  has_many :category_linkings, as: :category_linkable, dependent: :destroy
  has_many :categories, through: :category_linkings

  has_many :custom_model_type_linkings, as: :linkable
  has_many :custom_model_types, through: :custom_model_type_linkings

  delegate :translated_bookable_noun, :create_translations!, :translation_namespace,
    :translation_namespace_was, :translation_key_suffix, :translation_key_suffix_was,
    :translation_key_pluralized_suffix, :translation_key_pluralized_suffix_was, :underscore, to: :translation_manager


  def translation_manager
    @translation_manager ||= InstanceProfileType::InstanceProfileTypeTranslationManager.new(self)
  end

end
