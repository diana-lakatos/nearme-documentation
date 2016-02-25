class UserProfile < ActiveRecord::Base
  include Categorizable

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :instance_profile_type

  has_custom_attributes target_type: 'InstanceProfileType', target_id: :instance_profile_type_id

  SELLER  = 'seller'.freeze
  BUYER = 'buyer'.freeze
  DEFAULT = 'default'.freeze
  PROFILE_TYPES = [SELLER, BUYER, DEFAULT].freeze

  validates_inclusion_of :profile_type, in: PROFILE_TYPES

  before_create :assign_defaults

  scope :seller, -> { where(profile_type: SELLER) }
  scope :buyer, -> { where(profile_type: BUYER) }
  scope :default, -> { where(profile_type: DEFAULT) }
  scope :by_search_query, lambda { |query|
    joins(:user).merge(User.by_search_query(query))
  }

  def custom_validators
    instance_profile_type.try(:custom_validators)
  end

  def field_blank_or_changed?(field_name)
    return true unless self.persisted?
    db_field_value = UserProfile.find_by(id: self.id).properties[field_name]
    self.properties[field_name].blank? || (db_field_value != self.properties[field_name])
  end

  def category_blank_or_changed?(category)
    return true unless self.persisted?
    db_value = UserProfile.find_by(id: self.id).common_categories(category)
    self.common_categories(category).blank? || (db_value != self.common_categories(category))
  end

  def validate_mandatory_categories
    instance_profile_type.try(:categories).try(:mandatory).try(:each) do |mandatory_category|
      errors.add(mandatory_category.name, I18n.t('errors.messages.blank')) if common_categories(mandatory_category).blank?
    end
  end

  private

  def assign_defaults
    self.instance_profile_type ||= PlatformContext.current.instance.try("#{self.profile_type}_profile_type")
  end

end

