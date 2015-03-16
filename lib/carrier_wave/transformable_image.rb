module CarrierWave::TransformableImage
  extend ActiveSupport::Concern

  included do
    version :transformed do
      process :apply_rotate
      process :apply_crop
    end
  end

  def aspect_ratio
    self.class::ASPECT_RATIO
  end

  def apply_crop
    unless transformation_crop.empty?
      crop = transformation_crop

      manipulate! do |img|
        factor_x = factor_y = 0
        begin
          img_height, img_width = img.dimensions
          size_difference = (img_width - img_height).abs
          if transformation_rotate.present? && (transformation_rotate == 90 || transformation_rotate == 270)
            if img_width < img_height
              factor_y = -(size_difference / 2)
              factor_x = +(size_difference / 2)
            else
              factor_x = -(size_difference / 2)
              factor_y = +(size_difference / 2)
            end
          end
        rescue
          factor_x = factor_y = 0
        end

        crop[:x] = crop[:x].to_f + factor_x
        crop[:y] = crop[:y].to_f + factor_y
        img.crop "#{crop[:w]}x#{crop[:h]}+#{crop[:x]}+#{crop[:y]}"
        img
      end
    end
  end

  def apply_rotate
    unless transformation_rotate.zero?
      manipulate! do |img|
        img.rotate transformation_rotate.to_s
        img
      end
    end
  end

  def transformation_crop
    transformation_data[:crop] || {}
  end

  def transformation_rotate
    transformation_data[:rotate].try(:to_i) || 0
  end

  def transformation_data
    case data = model["#{mounted_as}_transformation_data"]
    when String
      YAML.load(data)
    else
      data
    end || {}
  end

end

