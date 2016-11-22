# encoding: utf-8
# frozen_string_literal: true
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
  end

  version :medium do
    process dynamic_version: :medium
  end

  ASPECT_RATIO = 6.7368421053
end
