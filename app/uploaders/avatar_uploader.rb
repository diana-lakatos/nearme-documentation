# encoding: utf-8
# frozen_string_literal: true
class AvatarUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::DynamicPhotoUploads
  include CarrierWave::ImageDefaults
  include CarrierWave::Cleanable

  self.dimensions = {
    thumb: { width: 96, height: 96, transform: :resize_to_fill },
    medium: { width: 144, height: 144, transform: :resize_to_fill },
    big: { width: 279, height: 279, transform: :resize_to_fill },
    bigger: { width: 460, height: 460, transform: :resize_to_fill }
  }

  ASPECT_RATIO = 1

  version :thumb, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :thumb
  end

  version :medium, from_version: :transformed do
    process dynamic_version: :medium
  end

  version :big, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :big
  end

  version :bigger, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :bigger
  end

  def default_placeholder(*_args)
    ActionController::Base.helpers.image_url('default-user-avatar.svg')
  end
end
