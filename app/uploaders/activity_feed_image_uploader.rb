# frozen_string_literal: true
# encoding: utf-8
class ActivityFeedImageUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::ImageDefaults
  include CarrierWave::DynamicPhotoUploads
  include CarrierWave::Cleanable
  ASPECT_RATIO = 1


  self.dimensions = {
    medium: { width: 144, height: 144, transform: :resize_to_fill },
    space_listing: { width: 410, height: 254, transform: :resize_to_fill }
  }

  version :medium, from_version: :transformed do
    process dynamic_version: :medium
  end

  version :space_listing, from_version: :transformed do
    process dynamic_version: :space_listing
  end

end
