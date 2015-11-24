class FormComponent < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  SPACE_WIZARD = 'space_wizard'
  PRODUCT_ATTRIBUTES = 'product_attributes'
  PROJECT_ATTRIBUTES = 'project_attributes'
  TRANSACTABLE_ATTRIBUTES = 'transactable_attributes'
  INSTANCE_PROFILE_TYPES = 'instance_profile_types'
  FORM_TYPES = [SPACE_WIZARD, PRODUCT_ATTRIBUTES, TRANSACTABLE_ATTRIBUTES, INSTANCE_PROFILE_TYPES, PROJECT_ATTRIBUTES]

  include RankedModel

  belongs_to :form_componentable, -> { with_deleted }, polymorphic: true, touch: true
  belongs_to :instance
  validates_inclusion_of :form_type, in: FORM_TYPES, allow_nil: false
  validates_length_of :name, maximum: 255

  serialize :form_fields, Array

  ranks :rank, with_same: [:form_componentable_id, :form_type]

  def fields_names
    form_fields.inject([]) do |all_fields_names, field|
      all_fields_names << field[field.keys.first]
      all_fields_names
    end
  end

  def form_types(form_componentable)
    if form_componentable.instance_of?(InstanceProfileType)
      [INSTANCE_PROFILE_TYPES]
    elsif form_componentable.instance_of?(ServiceType)
      [SPACE_WIZARD, TRANSACTABLE_ATTRIBUTES]
    elsif form_componentable.instance_of?(Spree::ProductType)
      [SPACE_WIZARD, PRODUCT_ATTRIBUTES]
    elsif form_componentable.instance_of?(ProjectType)
      [SPACE_WIZARD, PROJECT_ATTRIBUTES]
    else
      raise NotImplementedError
    end
  end
end

