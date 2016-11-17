# frozen_string_literal: true
# Used in UserBlogPost only
class AuthorAvatarUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::DynamicPhotoUploads
  include CarrierWave::ImageDefaults

  self.dimensions = {
    thumb: { width: 96, height: 96, transform: :resize_to_fill },
    medium: { width: 144, height: 144, transform: :resize_to_fill },
    big: { width: 279, height: 279, transform: :resize_to_fill }
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
end
