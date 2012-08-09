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

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
