# frozen_string_literal: true
class GroupCoverImageUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::ImageDefaults
  include CarrierWave::DynamicPhotoUploads
  include CarrierWave::Cleanable

  self.dimensions = {
    medium: { width: 720, height: nil, transform: :resize_to_fit },
    thumbnail: { width: 200, height: 175, transform: :resize_to_fill }
  }

  version :medium do
    process dynamic_version: :medium
  end

  version :thumbnail do
    process dynamic_version: :thumbnail
  end
end
