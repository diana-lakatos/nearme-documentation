class ThemeImageUploader < BaseImageUploader
  include CarrierWave::InkFilePicker
  include CarrierWave::TransformableImage

  def default_url
    nil
  end

end

