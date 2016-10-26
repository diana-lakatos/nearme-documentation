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
  after_create :update_es_mapping, if: ->(ca) { %w(TransactableType InstanceProfileType).include?(ca.target_type) }

  scope :searchable, -> { where(searchable: true) }
  scope :public_display, -> { where(public: true) }

  validates :valid_values, presence: { if: :searchable }
  validates :min_value, :max_value, :step, presence: true, if: -> { html_tag.eql?('range') }

  delegate :update_es_mapping, to: :target

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

  private

  def add_to_csv
    if required? && target.try(:custom_csv_fields)
      unless target.custom_csv_fields.include?(custom_attribute_for_csv)
        target.custom_csv_fields << custom_attribute_for_csv
        target.save!
      end
    end
  end
end
