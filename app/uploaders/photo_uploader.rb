# encoding: utf-8
class PhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/photos/#{model.id}/"
  end

  version :thumb do
    process :resize_to_fill => [96, 96]
  end

  version :medium do
    process :resize_to_fill => [144, 144]
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
    process :resize_to_fill => [895, 554]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def default_url
    "http://placehold.it/100x100"
  end
end
