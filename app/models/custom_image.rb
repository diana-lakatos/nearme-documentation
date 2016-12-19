# frozen_string_literal: true
class CustomImage < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :owner, polymorphic: true, touch: true
  belongs_to :custom_attribute, -> { with_deleted }, class_name: 'CustomAttributes::CustomAttribute'
  belongs_to :instance

  # validates :image, presence: true
  # validates :owner, presence: true

  mount_uploader :image, CustomImageUploader

  skip_callback :commit, :after, :remove_image!

  delegate :aspect_ratio, :settings_for_version,
           :optimization_settings, to: :custom_attribute
end
