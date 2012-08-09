# encoding: utf-8
class AvatarUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  after :remove, :clear_uploader

  def clear_uploader
    @file = @filename = @original_filename = @cache_id = @version = @storage = nil
    model.send(:write_attribute, mounted_as, nil)
  end


  def store_dir
    "media/#{model.class.to_s.underscore}/#{model.id}/#{mounted_as}"
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
