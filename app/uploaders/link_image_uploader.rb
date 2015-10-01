# encoding: utf-8
class LinkImageUploader < BaseImageUploader

  self.dimensions = {
    standard: { width: 240, height: 80 },
  }

  version :standard do
    process resize_to_fill: [dimensions[:standard][:width], dimensions[:standard][:height]]
  end

end
