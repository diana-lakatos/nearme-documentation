# encoding: utf-8
class AvatarUploader < BaseImageUploader
  include CarrierWave::InkFilePicker
  include CarrierWave::TransformableImage

  self.dimensions = {
    :thumb => { :width => 96, :height => 96 },
    :medium => { :width => 144, :height => 144 },
    :large => { :width => 1280, :height => 960 }
  }

  ASPECT_RATIO = 1

  def store_dir
    "media/#{model.class.to_s.underscore}/#{model.id}/#{mounted_as}"
  end

  version :thumb, :from_version => :transformed do
    process :resize_to_fill => [dimensions[:thumb][:width], dimensions[:thumb][:height]]
  end

  version :medium, :from_version => :transformed do
    process :resize_to_fill => [dimensions[:medium][:width], dimensions[:medium][:height]]
  end

  version :large, :from_version => :transformed do
    process :resize_to_fill => [dimensions[:large][:width], dimensions[:large][:height]]
  end

end
