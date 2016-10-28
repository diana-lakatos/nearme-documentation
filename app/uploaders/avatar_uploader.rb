# encoding: utf-8
class AvatarUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::DynamicPhotoUploads
  include CarrierWave::ImageDefaults
  include CarrierWave::Cleanable

  self.dimensions = {
    thumb: { width: 96, height: 96, transform: :resize_to_fill },
    medium: { width: 144, height: 144, transform: :resize_to_fill },
    # community_small: { width: 250, height: 200, transform: :resize_to_fill }, -> medium
    big: { width: 279, height: 279, transform: :resize_to_fill },
    bigger: { width: 460, height: 460, transform: :resize_to_fill },
    large: { width: 1280, height: 960, transform: :resize_to_fill }
  }

  ASPECT_RATIO = 1

  version :thumb, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :thumb
    process optimize: OPTIMIZE_SETTINGS
  end

  version :medium, from_version: :transformed do
    process dynamic_version: :medium
    process optimize: OPTIMIZE_SETTINGS
  end

  version :big, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :big
    process optimize: OPTIMIZE_SETTINGS
  end

  version :bigger, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :bigger
    process optimize: OPTIMIZE_SETTINGS
  end

  version :large, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :large
    process optimize: OPTIMIZE_SETTINGS
  end

  def default_placeholder(*_args)
    ActionController::Base.helpers.image_url('default-user-avatar.svg')
  end
end
