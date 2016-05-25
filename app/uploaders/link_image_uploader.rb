# encoding: utf-8
class LinkImageUploader < BaseImageUploader

  self.dimensions = {
    standard: { width: 240, height: 80 },
    medium: { width: 144, height: 89 },
  }

  version :standard do
    process resize_to_fill: [dimensions[:standard][:width], dimensions[:standard][:height]]
  end

  version :medium do
    process resize_to_fill: [dimensions[:medium][:width], dimensions[:medium][:height]]
  end

end
