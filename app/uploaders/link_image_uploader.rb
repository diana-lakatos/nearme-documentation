# encoding: utf-8
# frozen_string_literal: true
class LinkImageUploader < BaseUploader
  include CarrierWave::DynamicPhotoUploads
  include CarrierWave::ImageDefaults

  self.dimensions = {
    standard: { width: 240, height: 80, transform: :resize_to_fill },
    medium: { width: 144, height: 89, transform: :resize_to_fill }
  }

  version :standard do
    process dynamic_version: :standard
  end

  version :medium do
    process dynamic_version: :medium
  end
end
