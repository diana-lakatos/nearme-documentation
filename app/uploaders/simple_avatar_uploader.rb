class SimpleAvatarUploader < BaseImageUploader
  include CarrierWave::MiniMagick

  self.dimensions = {
    :thumb => { :width => 96, :height => 96 },
    :medium => { :width => 144, :height => 144 }
  }

  version :thumb do
    process :resize_to_fill => [dimensions[:thumb][:width], dimensions[:thumb][:height]]
  end

  version :medium do
    process :resize_to_fill => [dimensions[:medium][:width], dimensions[:medium][:height]]
  end

end
