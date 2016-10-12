class SimpleAvatarUploader < BaseImageUploader
  include CarrierWave::MiniMagick
  include DynamicPhotoUploads

  self.dimensions = {
    thumb: { width: 96, height: 96, transform: :resize_to_fill },
    medium: { width: 144, height: 144, transform: :resize_to_fill }
  }

  version :thumb do
    process dynamic_version: :thumb
  end

  version :medium do
    process dynamic_version: :medium
  end
end
