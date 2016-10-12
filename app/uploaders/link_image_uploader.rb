# encoding: utf-8
class LinkImageUploader < BaseImageUploader
  include DynamicPhotoUploads

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
