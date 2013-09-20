class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  # Define the dimensions for versions of the uploader in a class attribute
  # that can be accessed by parts of the Uploader stack.
  class_attribute :dimensions
  self.dimensions = {}

  def dimensions
    self.class.dimensions
  end

  def thumbnail_dimensions
    dimensions
  end

  def original_dimensions
    if model["#{mounted_as}_original_width"] && model["#{mounted_as}_original_height"]
      [model["#{mounted_as}_original_width"], model["#{mounted_as}_original_height"]]
    else
      img = image
      [img[:width], img[:height]]
    end
  end

  def image
    # we don't want to assign this to variable, becuase there are issues with serialization in versions_regeneration_job
   MiniMagick::Image.open(current_url[0] == '/' ? Rails.root.join('public', current_url[1..-1]) : current_url)
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
