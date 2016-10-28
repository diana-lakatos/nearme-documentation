# encoding: utf-8
class TopicCoverImageUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::DynamicPhotoUploads
  include CarrierWave::ImageDefaults

  self.dimensions = {
    medium: { width: 575, height: 196, transform: :resize_to_fill },
    big: { width: 575, height: 441, transform: :resize_to_fill }
  }

  version :big do
    process dynamic_version: :big
    process optimize: OPTIMIZE_SETTINGS
  end

  version :medium do
    process dynamic_version: :medium
    process optimize: OPTIMIZE_SETTINGS
  end

  ASPECT_RATIO = 6.7368421053
end
