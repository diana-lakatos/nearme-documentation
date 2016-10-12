class ThemeImageUploader < BaseImageUploader
  include CarrierWave::TransformableImage

  def default_url
    nil
  end
end
