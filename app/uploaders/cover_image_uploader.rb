# encoding: utf-8
class CoverImageUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::ImageDefaults
  include CarrierWave::Cleanable

  ASPECT_RATIO = 6.7368421053

  cattr_reader :delayed_versions

  self.dimensions = {
    thumbail: { width: 200, height: 200 }
  }
end
