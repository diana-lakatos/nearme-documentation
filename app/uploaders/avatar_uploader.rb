# encoding: utf-8
class AvatarUploader < BaseUploader
  # note that we cannot change BaseUploader to BaseImageUploader
  # because of validation - avatars downloaded from social providers like
  # linkedin do not have extension
  include CarrierWave::TransformableImage
  include DynamicPhotoUploads

  cattr_reader :delayed_versions

  after :remove, :clean_model

  process :auto_orient

  def auto_orient
    manipulate! do |img|
      img.auto_orient
      img
    end
  end

  self.dimensions = {
    thumb: { width: 96, height: 96, transform: :resize_to_fill },
    medium: { width: 144, height: 144, transform: :resize_to_fill },
    community_small: { width: 250, height: 200, transform: :resize_to_fill },
    big: { width: 279, height: 279, transform: :resize_to_fill },
    bigger: { width: 460, height: 460, transform: :resize_to_fill },
    large: { width: 1280, height: 960, transform: :resize_to_fill }
  }

  ASPECT_RATIO = 1

  version :thumb, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :thumb
  end

  version :medium, from_version: :transformed do
    process dynamic_version: :medium
  end

  version :big, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :big
  end

  version :bigger, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :bigger
  end

  version :large, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :large
  end

  version :community_small do
    process dynamic_version: :community_small
  end

  def default_url(*args)
    default_image, version = get_default_image_and_version(*args)

    if default_image.blank? || self.class == DefaultImageUploader
      ActionController::Base.helpers.image_url('default-user-avatar.svg')
    else
      default_image.photo_uploader_image.url(:transformed)
    end
  end

  def clean_model
    model.update_attribute(:avatar_transformation_data, nil)
  end
end
