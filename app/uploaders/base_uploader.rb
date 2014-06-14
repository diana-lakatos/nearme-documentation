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
      img.nil? ? [] : [img[:width], img[:height]]
    end
  end

  def image
    img_path = self.respond_to?(:current_url) ? current_url(:original) : self.url
    # we don't want to assign this to variable, becuase there are issues with serialization in versions_regeneration_job
    MiniMagick::Image.open(img_path[0] == '/' ? Rails.root.join('public', img_path[1..-1]) : img_path)
  rescue
    nil
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{instance_prefix}/uploads/images/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def legacy_store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def platform_context
    PlatformContext.current
  end

  def instance_prefix
    platform_context.present? ? platform_context.instance.id : 'universal'
  end
end
