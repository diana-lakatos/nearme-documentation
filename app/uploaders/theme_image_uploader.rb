# frozen_string_literal: true
class ThemeImageUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::ImageDefaults
end
