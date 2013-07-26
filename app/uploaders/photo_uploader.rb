# encoding: utf-8
class PhotoUploader < BaseImageUploader
  SPACE_FULL_IMAGE_W = 895
  SPACE_FULL_IMAGE_H = 554

  def store_dir
    "uploads/photos/#{model.id}/"
  end

  process :auto_orient

  version :thumb do
    process :resize_to_fill => [96, 96]
  end

  version :medium do
    process :resize_to_fill => [144, 89]
  end

  version :large do
    process :resize_to_fill => [1280, 960]
  end

  version :hero do
    process :resize_to_fill => [960, 350]
  end

  version :hero_preview do
    process :resize_to_fill => [100, 70]
  end

  version :space_listing do
    process :resize_to_fill => [410, 254]
  end

  version :golden do
    process :resize_to_fill => [SPACE_FULL_IMAGE_W, SPACE_FULL_IMAGE_H]
  end

  def auto_orient
    manipulate! do |img|
      img.auto_orient
      img
    end
  end

  def default_url
    "http://placehold.it/100x100"
  end
end
