# encoding: utf-8
class PhotoUploader < BaseImageUploader

  include CarrierWave::TransformableImage

  cattr_reader :delayed_versions

  SPACE_FULL_IMAGE_W = 895
  SPACE_FULL_IMAGE_H = 554

  self.dimensions = {
    thumb: { width: 96, height: 96 },
    medium: { width: 144, height: 89 },
    large: { width: 1280, height: 960 },
    space_listing: { width: 410, height: 254 },
    #project_standard: { width: 460, height: 340 },
    project_cover: { width: 680, height: 546 },
    project_thumbnail: { width: 200, height: 175 },
    project_thumbnail_to_fit: { :width => 460, :height => 460 },
    project_small: { width: 250, height: 200 },
    golden: { width: SPACE_FULL_IMAGE_W, height: SPACE_FULL_IMAGE_H },
  }

  ASPECT_RATIO = 16.0/10.0
  ASPECT_RATIO_PROJECT = 8.0/7.0

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

  version :thumb, from_version: :transformed, if: :generate_transactable_versions? do
    process resize_to_fill: [dimensions[:thumb][:width], dimensions[:thumb][:height]]
  end

  version :medium, from_version: :transformed do
    process resize_to_fill: [dimensions[:medium][:width], dimensions[:medium][:height]]
  end

  version :large, from_version: :transformed, if: :generate_transactable_versions? do
    process resize_to_fill: [dimensions[:large][:width], dimensions[:large][:height]]
  end

  version :space_listing, from_version: :transformed, if: :generate_transactable_versions? do
    process resize_to_fill: [dimensions[:space_listing][:width], dimensions[:space_listing][:height]]
  end

  version :golden, from_version: :transformed, if: :generate_transactable_versions? do
    process resize_to_fill: [dimensions[:golden][:width], dimensions[:golden][:height]]
  end

  version :project_cover, from_version: :transformed, if: :generate_project_versions? do
    process resize_to_fill: [dimensions[:project_cover][:width], dimensions[:project_cover][:height]]
  end

  version :project_thumbnail, from_version: :transformed, if: :generate_project_versions? do
    process resize_to_fill: [dimensions[:project_thumbnail][:width], dimensions[:project_thumbnail][:height]]
  end

  version :project_thumbnail_to_fit, from_version: :transformed, if: :generate_project_versions? do
    process resize_to_fit: [dimensions[:project_thumbnail_to_fit][:width], dimensions[:project_thumbnail_to_fit][:height]]
  end

  version :project_small, from_version: :transformed, if: :generate_project_versions? do
    process resize_to_fill: [dimensions[:project_small][:width], dimensions[:project_small][:height]]
  end

  def generate_transactable_versions?(image)
    delayed_processing? && model.try(:owner_type) != 'Project'
  end

  def generate_project_versions?(image)
    model.try(:owner_type) == 'Project'
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
