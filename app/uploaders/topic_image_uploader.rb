# encoding: utf-8
class TopicImageUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::DynamicPhotoUploads
  include CarrierWave::ImageDefaults

  self.dimensions = {
    small: { width: 250, height: 200, transform: :resize_to_fill },
    medium: { width: 460, height: 340, transform: :resize_to_fill }
  }

  version :small do
    process dynamic_version: :small
    process optimize: OPTIMIZE_SETTINGS
  end

  version :medium do
    process dynamic_version: :medium
    process optimize: OPTIMIZE_SETTINGS
  end

  ASPECT_RATIO = 8.0 / 7.0
end
