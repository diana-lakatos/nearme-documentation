# encoding: utf-8
class AvatarUploader < BaseUploader
  # note that we cannot change BaseUploader to BaseImageUploader
  # because of validation - avatars downloaded from social providers like
  # linkedin do not have extension
  include CarrierWave::TransformableImage

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
    :thumb => { :width => 96, :height => 96 },
    :medium => { :width => 144, :height => 144 },
    :community_thumbnail => { :width => 200, :height => 200 },
    :community_small => { :width => 250, :height => 200 },
    :big => { :width => 279, :height => 279 },
    :bigger => { :width => 460, :height => 460 },
    :large => { :width => 1280, :height => 960 }
  }

  ASPECT_RATIO = 1

  # tmp hack to make avatars work
  def instance_id
    instance_id_nil
  end

  def legacy_store_dir
    "media/#{model.class.to_s.underscore}/#{model.id}/#{mounted_as}"
  end

  version :thumb, from_version: :transformed, if: :delayed_processing? do
    process resize_to_fill: [dimensions[:thumb][:width], dimensions[:thumb][:height]]
  end

  version :medium, from_version: :transformed do
    process resize_to_fill: [dimensions[:medium][:width], dimensions[:medium][:height]]
  end

  version :big, from_version: :transformed, if: :delayed_processing? do
    process resize_to_fill: [dimensions[:big][:width], dimensions[:big][:height]]
  end

  version :bigger, from_version: :transformed, if: :delayed_processing? do
    process resize_to_fill: [dimensions[:bigger][:width], dimensions[:bigger][:height]]
  end

  version :large, from_version: :transformed, if: :delayed_processing? do
    process resize_to_fill: [dimensions[:large][:width], dimensions[:large][:height]]
  end

  version :community_small do
    process resize_to_fill: [dimensions[:community_small][:width], dimensions[:community_small][:height]]
  end


  def default_url(*args)
    ActionController::Base.helpers.image_url('default-user-avatar.svg')
  end

  def clean_model
    model.update_attribute(:avatar_transformation_data, nil)
  end

  def instance_id
    instance_id_nil
  end
end
