# frozen_string_literal: true
class UserProfile < ActiveRecord::Base
  include Categorizable
  include AvailabilityHelpers
  include CustomImagesOwnerable
  include CustomAttachmentsOwnerable
  include CustomizationsOwnerable
  include CategoriesOwnerable

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user, touch: true
  belongs_to :instance_profile_type
  belongs_to :availability_template

  has_many :availability_templates, as: :parent

  accepts_nested_attributes_for :availability_template
  accepts_nested_attributes_for :custom_images
  accepts_nested_attributes_for :customizations, allow_destroy: true

  has_custom_attributes target_type: 'InstanceProfileType', target_id: :instance_profile_type_id

  delegate :onboarding, :onboarding?, :has_fields?, :custom_attributes_custom_validators,
           :default_availability_template, to: :instance_profile_type, allow_nil: true

  delegate :time_zone, to: :user
  alias timezone time_zone

  after_create :create_company_if_needed

  SELLER = 'seller'
  BUYER = 'buyer'
  DEFAULT = 'default'
  PROFILE_TYPES = [SELLER, BUYER, DEFAULT].freeze

  validates :profile_type, inclusion: { in: PROFILE_TYPES }

  before_create :assign_defaults

  scope :seller, -> { where(profile_type: SELLER) }
  scope :buyer, -> { where(profile_type: BUYER) }
  scope :default, -> { where(profile_type: DEFAULT) }
  scope :by_search_query, lambda { |query|
    joins(:user).merge(User.by_search_query(query))
  }
  scope :filtered_by_custom_attribute, ->(property, values) { where("string_to_array((user_profiles.properties->?), ',') && ARRAY[?]", property, values) unless values.blank? }

  def enabled
    check_approved && super
  end

  def check_approved
    instance_profile_type&.admin_approval? ? approved : true
  end

  def custom_validators
    instance_profile_type.try(:custom_validators)
  end

  def field_blank_or_changed?(field_name)
    return true unless persisted?
    db_field_value = UserProfile.find_by(id: id).properties[field_name]
    properties[field_name].blank? || (db_field_value != properties[field_name])
  end

  def category_blank_or_changed?(category)
    return true unless persisted?
    db_value = UserProfile.find_by(id: id).common_categories(category)
    common_categories(category).blank? || (db_value != common_categories(category))
  end

  def validate_mandatory_categories
    instance_profile_type.try(:categories).try(:mandatory).try(:each) do |mandatory_category|
      errors.add(mandatory_category.name, I18n.t('errors.messages.blank')) if common_categories(mandatory_category).blank?
    end
  end

  def to_liquid
    @user_profile_drop ||= UserProfileDrop.new(self)
  end

  def mark_as_onboarded!
    if onboarded_at.nil?
      touch(:onboarded_at)
      if profile_type == BUYER
        WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::EnquirerOnboarded, user_id)
      elsif profile_type == SELLER
        WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::ListerOnboarded, user_id)
      end
      true
    else
      false
    end
  end

  private

  def assign_defaults
    self.instance_profile_type ||= PlatformContext.current.instance.try("#{profile_type}_profile_type")
    # by default, seller and buyer profiles are enabled only if onboarding is disabled. Default profile is always enabled.
    self.enabled = !onboarding? || profile_type == DEFAULT
    true
  end

  def create_company_if_needed
    if instance_profile_type.try(:create_company_on_sign_up?) && user.companies.count.zero?
      company = user.companies.create!(name: user.name, creator: user)
      company.update_metadata(draft_at: nil, completed_at: Time.zone.now)
    end
    true
  end
end
