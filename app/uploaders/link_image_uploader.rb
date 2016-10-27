# encoding: utf-8
class LinkImageUploader < BaseUploader
  include CarrierWave::DynamicPhotoUploads
  include CarrierWave::ImageDefaults

  self.dimensions = {
    standard: { width: 240, height: 80, transform: :resize_to_fill },
    medium: { width: 144, height: 89, transform: :resize_to_fill }
  }

  version :standard do
    process dynamic_version: :standard
    process optimize: OPTIMIZE_SETTINGS
  end

  version :medium do
    process dynamic_version: :medium
    process optimize: OPTIMIZE_SETTINGS
  end
end
