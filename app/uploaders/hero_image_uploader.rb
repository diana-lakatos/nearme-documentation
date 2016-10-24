class HeroImageUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::DynamicPhotoUploads
  include CarrierWave::ImageDefaults

  self.dimensions = {
    medium: { width: 720, height: nil, transform: :resize_to_fit }
  }

  version :medium, from_version: :optimized do
    process dynamic_version: :medium
  end
end
