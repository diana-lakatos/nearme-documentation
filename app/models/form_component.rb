class FormComponent < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  SPACE_WIZARD = 'space_wizard'
  PRODUCT_ATTRIBUTES = 'product_attributes'
  TRANSACTABLE_ATTRIBUTES = 'transactable_attributes'
  FORM_TYPES = [SPACE_WIZARD, PRODUCT_ATTRIBUTES, TRANSACTABLE_ATTRIBUTES]

  include RankedModel

  belongs_to :form_componentable, polymorphic: true, touch: true
  belongs_to :instance
  validates_inclusion_of :form_type, in: FORM_TYPES, allow_nil: false

  serialize :form_fields, Array

  ranks :rank, with_same: [:form_componentable_id, :form_type]

  def fields_names
    form_fields.inject([]) do |all_fields_names, field|
      all_fields_names << field[field.keys.first]
      all_fields_names
    end
  end
end

