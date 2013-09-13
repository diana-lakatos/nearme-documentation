# encoding: utf-8
class PhotoUploader < BaseImageUploader
  include CarrierWave::InkFilePicker
  include CarrierWave::TransformableImage

  SPACE_FULL_IMAGE_W = 895
  SPACE_FULL_IMAGE_H = 554
  self.dimensions = {
    :thumb => { :width => 96, :height => 96 },
    :medium => { :width => 144, :height => 89 },
    :large => { :width => 1280, :height => 960 },
    :space_listing => { :width => 410, :height => 254 },
    :golden => { :width => SPACE_FULL_IMAGE_W, :height => SPACE_FULL_IMAGE_H },
  }

  ASPECT_RATIO = 16.0/10.0

  def store_dir
    "uploads/photos/#{model.id}/"
  end

  def filename
    if model.read_attribute(mounted_as).present?
      model.read_attribute(mounted_as) if original_filename.present?
    else
      "#{secure_token}.#{file.extension}" if original_filename.present?
    end
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

  version :space_listing, :from_version => :transformed do
    process :resize_to_fill => [dimensions[:space_listing][:width], dimensions[:space_listing][:height]]
  end

  version :golden, :from_version => :transformed do
    process :resize_to_fill => [dimensions[:golden][:width], dimensions[:golden][:height]]
  end

  include NewrelicCarrierwaveTracker

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

end
