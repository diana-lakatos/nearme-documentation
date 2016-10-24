# encoding: utf-8
class TopicImageUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::DynamicPhotoUploads
  include CarrierWave::ImageDefaults

  self.dimensions = {
    small: { width: 250, height: 200, transform: :resize_to_fill },
    medium: { width: 460, height: 340, transform: :resize_to_fill }
  }

  version :small, from_version: :optimized do
    process dynamic_version: :small
  end

  version :medium, from_version: :optimized do
    process dynamic_version: :medium
  end

  ASPECT_RATIO = 8.0 / 7.0
end
