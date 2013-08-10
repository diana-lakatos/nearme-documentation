class BaseImageUploader < BaseUploader
  include CarrierWave::MiniMagick

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg png gif)
  end

  # Offers a placeholder while image is not uploaded yet
  def default_url
    "http://placehold.it/100x100"
  end

  def crop(crop_params)
    manipulate! do |img|
      img.crop parse_crop_params(crop_params)
      img
    end
  end

  def rotate(angle)
    manipulate! do |img|
      img.rotate angle
      img
    end
  end

  def image
    @image ||= MiniMagick::Image.open( model.send(mounted_as).path )
  end

  def width
    image[:width]
  end

  def height
    image[:height]
  end

  private

  def parse_crop_params(params)
    "#{params[:w].to_i}x#{params[:h].to_i}+#{params[:x].to_i}+#{params[:y].to_i}"
  end
end
