# encoding: utf-8
class PhotoUploader < BaseImageUploader
  SPACE_FULL_IMAGE_W = 895
  SPACE_FULL_IMAGE_H = 554

  def store_dir
    "uploads/photos/#{model.id}/"
  end

  def filename
    if model.versions_generated?
      original_filename if original_filename.present?
    else
      "#{secure_token}.#{file.extension}" if original_filename.present?
    end
  end

  process :auto_orient

  version :adjusted do
    process :apply_rotate
    process :apply_crop
  end

  version :thumb, :from_version => :adjusted, :if => :should_generate_versions? do
    process :resize_to_fill => [96, 96]
  end

  # it's not a mistake that we don't have :if condition here - we want to be able to display img preview ASAP
  version :medium, :from_version => :adjusted do
    process :resize_to_fill => [144, 89]
  end

  version :large, :from_version => :adjusted, :if => :should_generate_versions? do
    process :resize_to_fill => [1280, 960]
  end

  version :space_listing, :from_version => :adjusted, :if => :should_generate_versions? do
    process :resize_to_fill => [410, 254]
  end

  version :golden, :from_version => :adjusted, :if => :should_generate_versions? do
    process :resize_to_fill => [SPACE_FULL_IMAGE_W, SPACE_FULL_IMAGE_H]
  end

  def auto_orient
    manipulate! do |img|
      img.auto_orient
      img
    end
  end

  include NewrelicCarrierwaveTracker

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

  private

  def should_generate_versions?(*args)
    model.should_generate_versions?
  end

  def apply_crop
    return if [model.crop_x, model.crop_y, model.crop_w, model.crop_h].any? &:nil?

    manipulate! do |img|
      img.crop "#{model.crop_w.to_s}x#{model.crop_h.to_s}+#{model.crop_x.to_s}+#{model.crop_y.to_s}"
      img
    end
  end

  def apply_rotate
    return unless model.rotation_angle
    manipulate! do |img|
      img.rotate model.rotation_angle.to_s
      img
    end
  end
end
