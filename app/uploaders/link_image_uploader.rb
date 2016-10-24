# encoding: utf-8
class LinkImageUploader < BaseUploader
  include CarrierWave::DynamicPhotoUploads
  include CarrierWave::ImageDefaults

  self.dimensions = {
    standard: { width: 240, height: 80, transform: :resize_to_fill },
    medium: { width: 144, height: 89, transform: :resize_to_fill }
  }

  version :standard, from_version: :optimized do
    process dynamic_version: :standard
  end

  version :medium, from_version: :optimized do
    process dynamic_version: :medium
  end
end
