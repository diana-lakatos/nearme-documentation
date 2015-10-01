# encoding: utf-8
class TopicImageUploader < BaseUploader
  # note that we cannot change BaseUploader to BaseImageUploader
  # because of validation - cover images downloaded from social providers like
  # linkedin do not have extension
  include CarrierWave::TransformableImage

  cattr_reader :delayed_versions

  process :auto_orient


  self.dimensions = {
    small: { width: 250, height: 200 },
    medium: { width: 460, height: 340 }
  }

  version :small do
    process resize_to_fill: [dimensions[:small][:width], dimensions[:small][:height]]
  end
  version :medium do
    process resize_to_fill: [dimensions[:medium][:width], dimensions[:medium][:height]]
  end

  ASPECT_RATIO = 8.0/7.0

  def auto_orient
    manipulate! do |img|
      img.auto_orient
      img
    end
  end

end

