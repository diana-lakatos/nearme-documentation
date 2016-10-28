class ThemeImageUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::ImageDefaults

  def default_url(*_args)
    nil
  end
end
