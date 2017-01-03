# frozen_string_literal: true
class Customization < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  has_custom_attributes target_type: 'CustomModelType', target_id: :custom_model_type_id
  validates_with CustomValidators

  belongs_to :instance
  belongs_to :custom_model_type
  belongs_to :customizable, polymorphic: true, touch: true

  has_many :custom_images, as: :owner, dependent: :destroy
  accepts_nested_attributes_for :custom_images, allow_destroy: true

  delegate :custom_validators, to: :custom_model_type

  def custom_attributes_custom_validators
    @custom_attributes_custom_validators ||= { properties: custom_model_type.custom_attributes_custom_validators }
  end

  def to_liquid
    @customization_drop ||= CustomizationDrop.new(self)
  end
end
