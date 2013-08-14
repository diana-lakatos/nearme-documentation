# encoding: utf-8
class PhotoUploader < BaseImageUploader
  SPACE_FULL_IMAGE_W = 895
  SPACE_FULL_IMAGE_H = 554

  def store_dir
    "uploads/photos/#{model.id}/"
  end

  process :auto_orient

  version :thumb, :if => :should_generate_versions? do
    process :resize_to_fill => [96, 96]
  end

  # it's not a mistake that we don't have :if condition here - we want to be able to display img preview ASAP
  version :medium do
    process :resize_to_fill => [144, 89]
  end

  version :large, :if => :should_generate_versions? do
    process :resize_to_fill => [1280, 960]
  end

  version :space_listing, :if => :should_generate_versions? do
    process :resize_to_fill => [410, 254]
  end

  version :golden, :if => :should_generate_versions? do
    process :resize_to_fill => [SPACE_FULL_IMAGE_W, SPACE_FULL_IMAGE_H]
  end

  def auto_orient
    manipulate! do |img|
      img.auto_orient
      img
    end
  end

  include NewrelicCarrierwaveTracker

  private

  def should_generate_versions?(*args)
    model.should_generate_versions?
  end

end
