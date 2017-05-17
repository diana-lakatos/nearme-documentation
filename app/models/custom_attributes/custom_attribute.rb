# frozen_string_literal: true
class CustomAttributes::CustomAttribute < ActiveRecord::Base
  # defined in vendor/gems/custom_attributes/lib/custom_attributes/concerns
  include CustomAttributes::Concerns::Models::CustomAttribute
  include Cacheable

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  store_accessor :properties, :min_value, :max_value, :step
  after_save :create_translations, :add_to_csv

  scope :searchable, -> { where(searchable: true) }
  scope :public_display, -> { where(public: true) }
  scope :required, -> { joins(:custom_validators).merge(CustomValidator.required) }

  validates :valid_values, presence: { if: :searchable }
  validates :min_value, :max_value, :step, presence: true, if: -> { html_tag.eql?('range') }
  validates :name,
            uniqueness: {
              scope: [:instance_id, :deleted_at],
              message: ->(_, info) { "with value: '#{info[:value]}' already taken." }
            }, if: :uploadable?

  delegate :update_es_mapping, to: :target

  has_many :custom_validators, as: :validatable, dependent: :destroy
  accepts_nested_attributes_for :custom_validators, allow_destroy: true

  before_save :update_custom_validators
  after_save :ensure_custom_validators_are_properly_setup!

  serialize :settings, Hash
  store :settings, accessors: %i(versions_configuration optimization_settings aspect_ratio), coder: Hash

  mount_uploader :placeholder_image, CustomImageUploader

  DEFAULT_ASPECT_RATIO = 1.3
  DEFAULT_VERSION_SETTINGS = {
    mini: { width: 56, height: 56, transform: :resize_to_fill },
    thumb: { width: 144, height: 109, transform: :resize_to_fill },
    normal: { width: 1280, height: 960, transform: :resize_to_fill }
  }.freeze

  def aspect_ratio
    super.presence || DEFAULT_ASPECT_RATIO
  end

  def settings_for_version(version)
    version_settings = (versions_configuration || {}).fetch(version.to_s,
                                                            DEFAULT_VERSION_SETTINGS[version.to_sym]).with_indifferent_access
    [version_settings[:transform], version_settings[:width], version_settings[:height]]
  end

  def optimization_settings
    super.presence || CarrierWave::Optimizable::OPTIMIZE_SETTINGS
  end

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

  def uploadable?
    %w(photo file).include?(attribute_type)
  end

  private

  def ensure_custom_validators_are_properly_setup!
    if valid_values.any?
      custom_validator = custom_validators
                         .detect { |cv| cv.field_name == name && cv.valid_values.present? } || custom_validators.build
      if custom_validator.valid_values != valid_values
        custom_validator.valid_values = valid_values
        custom_validator.save!
      end
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
