class CustomAttributes::CustomAttribute < ActiveRecord::Base
  # defined in vendor/gems/custom_attributes/lib/custom_attributes/concerns
  include CustomAttributes::Concerns::Models::CustomAttribute
  include Cacheable

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  after_save :create_translations, :add_to_csv
  after_create :update_es_mapping, if: ->(ca) { %w(TransactableType InstanceProfileType).include?(ca.target_type) }

  scope :searchable, -> { where(searchable: true) }
  scope :public_display, -> { where(public: true) }
  scope :required, -> { joins(:custom_validators).merge(CustomValidator.required) }

  validates :valid_values, presence: { if: :searchable }

  delegate :update_es_mapping, to: :target

  has_many :custom_validators, as: :validatable
  accepts_nested_attributes_for :custom_validators

  before_save :update_custom_validators
  after_save :ensure_custom_validators_are_properly_setup!

  def create_translations
    ::CustomAttributes::CustomAttribute::TranslationCreator.new(self).create_translations!
    expire_cache_key(cache_type: 'Translation')
  end

  def expire_cache_options
    { target_type: target_type, target_id: target_id }
  end

  def to_liquid
    @custom_attribute_drop ||= CustomAttributeDrop.new(self)
  end

  def custom_attribute_object
    'transactable'
  end

  def custom_attribute_for_csv
    { custom_attribute_object => name }
  end

  def required?
    custom_validators.required.any?
  end

  private

  def ensure_custom_validators_are_properly_setup!
    if valid_values.any?
      custom_validator = custom_validators.where(field_name: name)
                                          .where.not(valid_values: nil)
                                          .where.not(valid_values: [])
                                          .first_or_initialize
      custom_validator.valid_values = valid_values
      custom_validator.save!
    end
    true
  end

  def update_custom_validators
    custom_validators.each(&:set_validation_rules)
  end

  def add_to_csv
    if required? && target.try(:custom_csv_fields)
      unless target.custom_csv_fields.include?(custom_attribute_for_csv)
        target.custom_csv_fields << custom_attribute_for_csv
        target.save!
      end
    end
  end
end
