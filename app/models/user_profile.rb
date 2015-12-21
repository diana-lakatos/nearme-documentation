class UserProfile < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :instance_profile_type

  has_custom_attributes target_type: 'InstanceProfileType', target_id: :instance_profile_type_id

  scope :by_search_query, lambda { |query|
    joins(:user).merge(User.by_search_query(query))
  }

  SELLER  = 'seller'.freeze
  BUYER = 'buyer'.freeze
  DEFAULT = 'default'.freeze
  PROFILE_TYPES = [SELLER, BUYER, DEFAULT].freeze

  validates_inclusion_of :profile_type, in: PROFILE_TYPES
  validate :validate_mandatory_categories, unless: ->(record) { record.skip_custom_attribute_validation }

  scope :seller, -> { where(profile_type: SELLER) }
  scope :buyer, -> { where(profile_type: BUYER) }
  scope :default, -> { where(profile_type: DEFAULT) }

  has_many :categories_categorizables, as: :categorizable
  has_many :categories, through: :categories_categorizables

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

  def category_ids=ids
    super(ids.map {|e| e.gsub(/\[|\]/, '').split(',')}.flatten.compact.map(&:to_i))
  end

  def common_categories(category)
    categories & category.descendants
  end

  def common_categories_json(category)
    JSON.generate(common_categories(category).map { |c| { id: c.id, name: c.translated_name }})
  end

end

