# encoding: utf-8
class AvatarUploader < BaseImageUploader

  def store_dir
    "media/#{model.class.to_s.underscore}/#{model.id}/#{mounted_as}"
  end

  process :auto_orient

  version :mini do
    process :resize_to_fill => [50, 50]
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

  def auto_orient
    manipulate! do |img|
      img.auto_orient
      img
    end
  end

end
