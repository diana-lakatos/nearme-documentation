class GroupCoverImageUploader < BaseUploader
  include CarrierWave::TransformableImage
  include DynamicPhotoUploads

  cattr_reader :delayed_versions
  process :auto_orient

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

  def auto_orient
    manipulate! do |img|
      img.auto_orient
      img
    end
  end

end
