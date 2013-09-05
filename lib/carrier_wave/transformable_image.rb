module CarrierWave::TransformableImage

  def aspect_ratio 
    self.class::ASPECT_RATIO
  end

  def apply_crop
    unless transformation_crop.empty?
      crop = transformation_crop
      manipulate! do |img|
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
    transformation_data && transformation_data[:crop] ?  transformation_data[:crop] : {}
  end

  def transformation_rotate
    transformation_data && transformation_data[:rotate] ?  transformation_data[:rotate].to_i : 0
  end

  def transformation_data
    if stored_transformation_data
      (String === stored_transformation_data ? YAML.load(stored_transformation_data) : stored_transformation_data)
    else
      {}
    end
  end

  def image
    @image ||= MiniMagick::Image.open(current_path)
  end

  def width
    image[:width]
  end

  def height
    image[:height]
  end

end
