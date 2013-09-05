# encoding: utf-8
class PhotoUploader < BaseImageUploader
  SPACE_FULL_IMAGE_W = 895
  SPACE_FULL_IMAGE_H = 554
  THUMBNAIL_DIMENSIONS = { 
    :thumb => { :width => 96, :height => 96 },
    :medium => { :width => 144, :height => 89 },
    :large => { :width => 1280, :height => 960 },
    :space_listing => { :width => 410, :height => 254 },
    :golden => { :width => SPACE_FULL_IMAGE_W, :height => SPACE_FULL_IMAGE_H },
  }
  ASPECT_RATIO = 16.0/10.0
  include CarrierWave::InkFilePicker
  include CarrierWave::TransformableImage

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

  version :space_listing, :from_version => :transformed do
    process :resize_to_fill => [THUMBNAIL_DIMENSIONS[:space_listing][:width], THUMBNAIL_DIMENSIONS[:space_listing][:height]]
  end

  version :golden, :from_version => :transformed do
    process :resize_to_fill => [THUMBNAIL_DIMENSIONS[:golden][:width], THUMBNAIL_DIMENSIONS[:golden][:height]]
  end

  include NewrelicCarrierwaveTracker

  def stored_transformation_data
    model.image_transformation_data
  end

  def stored_original_url
    model.image_original_url
  end

  def stored_versions_generated
    model.image_versions_generated_at
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

end
