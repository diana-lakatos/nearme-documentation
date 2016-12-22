# frozen_string_literal: true
class Customization < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  has_custom_attributes target_type: 'CustomModelType', target_id: :custom_model_type_id

  belongs_to :instance
  belongs_to :custom_model_type
  belongs_to :customizable, polymorphic: true, touch: true

  has_many :custom_images, as: :owner, dependent: :destroy
  accepts_nested_attributes_for :custom_images, allow_destroy: true

  def to_liquid
    @customization_drop ||= CustomizationDrop.new(self)
  end
end
