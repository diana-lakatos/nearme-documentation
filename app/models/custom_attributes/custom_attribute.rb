class CustomAttributes::CustomAttribute < ActiveRecord::Base
  # defined in vendor/gems/custom_attributes/lib/custom_attributes/concerns
  include CustomAttributes::Concerns::Models::CustomAttribute
  include Cacheable

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  after_save :create_translations, :add_to_csv

  scope :searchable, -> { where(searchable: true) }
  scope :public_display, -> { where(public: true) }

  validates_presence_of :valid_values, if: :searchable

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
    if self.required? && target.try(:custom_csv_fields)
      unless target.custom_csv_fields.include?(custom_attribute_for_csv)
        target.custom_csv_fields << custom_attribute_for_csv
        target.save!
      end
    end
  end
end
