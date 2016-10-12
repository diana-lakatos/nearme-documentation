# encoding: utf-8
class CoverImageUploader < BaseUploader
  # note that we cannot change BaseUploader to BaseImageUploader
  # because of validation - cover images downloaded from social providers like
  # linkedin do not have extension
  include CarrierWave::TransformableImage

  cattr_reader :delayed_versions

  after :remove, :clean_model

  process :auto_orient

  self.dimensions = {
    thumbail: { width: 200, height: 200 }
  }

  ASPECT_RATIO = 6.7368421053

  def auto_orient
    manipulate! do |img|
      img.auto_orient
      img
    end
  end

  def clean_model
    model.update_attribute(:cover_image_transformation_data, nil)
  end
end
