class ThemeImageUploader < BaseImageUploader
  def default_url
    nil
  end

  def capture_dimensions
    img = MiniMagick::Image::read(File.binread(@file.file))
    [img[:width], img[:height]]
  end
end
