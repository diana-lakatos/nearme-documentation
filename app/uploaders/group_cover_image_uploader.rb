class GroupCoverImageUploader < BaseUploader
  include CarrierWave::TransformableImage

  cattr_reader :delayed_versions
  process :auto_orient

  self.dimensions = {
    medium: { width: 720, height: nil },
    thumbnail: { width: 200, height: 175 }
  }

  version :medium do
    process resize_to_fit: [dimensions[:medium][:width], dimensions[:medium][:height]]
  end

  version :thumbnail do
    process resize_to_fill: [dimensions[:thumbnail][:width], dimensions[:thumbnail][:height]]
  end

  def auto_orient
    manipulate! do |img|
      img.auto_orient
      img
    end
  end

end
