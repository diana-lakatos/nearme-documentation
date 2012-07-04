# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore.pluralize}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  end

  # Create different versions of your uploaded files:
  version :thumb do
    process :resize_to_fill => [50, 50]
  end

  version :medium do
    process :resize_to_fill => [150, 150]
  end

  version :large do
    process :resize_to_fit => [800, 800]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
