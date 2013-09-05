# encoding: utf-8
class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  THUMBNAIL_DIMENSIONS = { 
    :thumb => { :width => 96, :height => 96 },
    :medium => { :width => 144, :height => 144 }, 
    :large => { :width => 1280, :height => 960 }
  }
  ASPECT_RATIO = 1
  include CarrierWave::InkFilePicker
  include CarrierWave::TransformableImage

  process :auto_orient

  def store_dir
    "media/#{model.class.to_s.underscore}/#{model.id}/#{mounted_as}"
  end

  version :transformed do
    process :apply_crop
    process :apply_rotate
  end

  version :thumb, :from_version => :transformed do
    process :resize_to_fill => [THUMBNAIL_DIMENSIONS[:thumb][:width], THUMBNAIL_DIMENSIONS[:thumb][:height]]
  end

  version :medium, :from_version => :transformed do
    process :resize_to_fill => [THUMBNAIL_DIMENSIONS[:medium][:width], THUMBNAIL_DIMENSIONS[:medium][:height]]
  end

  version :large, :from_version => :transformed do
    process :resize_to_fill => [THUMBNAIL_DIMENSIONS[:large][:width], THUMBNAIL_DIMENSIONS[:large][:height]]
  end

  def default_url
    Placeholder.new(height: 100, width: 100).path
  end

  def auto_orient
    manipulate! do |img|
      img.auto_orient
      img
    end
  end

  def stored_transformation_data
    model.avatar_transformation_data
  end

  def stored_original_url
    model.avatar_original_url
  end

  def stored_versions_generated
    model.avatar_versions_generated_at
  end

end
