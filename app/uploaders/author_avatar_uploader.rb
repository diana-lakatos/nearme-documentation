# Used in UserBlogPost only
class AuthorAvatarUploader < BaseImageUploader
  include CarrierWave::TransformableImage
  include DynamicPhotoUploads

  self.dimensions = {
    thumb: { width: 96, height: 96, transform: :resize_to_fill },
    medium: { width: 144, height: 144, transform: :resize_to_fill },
    big: { width: 279, height: 279, transform: :resize_to_fill },
    large: { width: 1280, height: 960, transform: :resize_to_fill }
  }

  version :thumb, from_version: :transformed do
    process dynamic_version: :thumb
  end

  version :medium, from_version: :transformed do
    process dynamic_version: :medium
  end

  version :big, from_version: :transformed do
    process dynamic_version: :big
  end

  version :large, from_version: :transformed do
    process dynamic_version: :large
  end
end
