class InstanceProfileType < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  acts_as_custom_attributes_set
  belongs_to :instance
  has_many :users

  has_many :form_components, as: :form_componentable
  has_many :category_linkings, as: :category_linkable, dependent: :destroy
  has_many :categories, through: :category_linkings

  delegate :translation_namespace, :translation_namespace_was, :translation_key_suffix, :translation_key_suffix_was,
    :translation_key_pluralized_suffix, :translation_key_pluralized_suffix_was, :underscore, to: :translation_manager

  DEFAULT  = 'default'.freeze
  SELLER  = 'seller'.freeze
  BUYER = 'buyer'.freeze
  PROFILE_TYPES = [DEFAULT, SELLER, BUYER].freeze

  validates_inclusion_of :profile_type, in: PROFILE_TYPES

  scope :default, -> { where(profile_type: DEFAULT) }
  scope :seller, -> { where(profile_type: SELLER) }
  scope :buyer, -> { where(profile_type: BUYER) }

  def translation_manager
    @translation_manager ||= InstanceProfileType::InstanceProfileTypeTranslationManager.new(self)
  end

end

