# frozen_string_literal: true
# encoding: utf-8
class PhotoUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::DynamicPhotoUploads
  include CarrierWave::ImageDefaults

  SPACE_FULL_IMAGE_W = 895
  SPACE_FULL_IMAGE_H = 554

  self.dimensions = {
    thumb: { width: 96, height: 96, transform: :resize_to_fill },
    medium: { width: 144, height: 89, transform: :resize_to_fill },
    large: { width: 1280, height: 960, transform: :resize_to_fill },
    space_listing: { width: 410, height: 254, transform: :resize_to_fill },
    # project_cover: { width: 680, height: 546, transform: :resize_to_fill }, -> fullscreen
    # project_thumbnail: { width: 200, height: 175, transform: :resize_to_fill }, -> thumb
    # project_small: { width: 250, height: 200, transform: :resize_to_fill }, -> medium
    golden: { width: SPACE_FULL_IMAGE_W, height: SPACE_FULL_IMAGE_H, transform: :resize_to_fill },
    # fullscreen: { width: 1200, height: 800, transform: :resize_to_fit },  -> space_listing
    # fit_to_activity_feed: { width: 600, height: 482, transform: :resize_to_fill } -> space_listing
  }

  ASPECT_RATIO = 16.0 / 10.0
  ASPECT_RATIO_PROJECT = 8.0 / 7.0

  def store_dir
    "#{instance_prefix}/uploads/images/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def legacy_store_dir
    "uploads/photos/#{model.id}/"
  end

  def filename
    if model.read_attribute(mounted_as).present?
      model.read_attribute(mounted_as) if original_filename.present?
    else
      "#{secure_token}.#{file.extension}" if original_filename.present?
    end
  end

  version :thumb, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :thumb
  end

  version :medium, from_version: :transformed do
    process dynamic_version: :medium
  end

  version :large, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :large
  end

  version :space_listing, from_version: :transformed do
    process dynamic_version: :space_listing
  end

  version :golden, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :golden
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) || model.instance_variable_set(var, SecureRandom.uuid)
  end
end
