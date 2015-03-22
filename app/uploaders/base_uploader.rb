class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  attr_accessor :delayed_processing

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
      read_original_dimensions
    end
  end

  def read_original_dimensions
    img = image
    img.nil? ? [] : [img[:width], img[:height]]
  end

  def proper_file_path
    img_path = self.respond_to?(:current_url) ? current_url(:original) : self.url
    img_path[0] == '/' ? Rails.root.join('public', img_path[1..-1]) : img_path
  end

  def image
    # we don't want to assign this to variable, becuase there are issues with serialization in versions_regeneration_job
    MiniMagick::Image.open(proper_file_path)
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
    "instances/#{instance_id}"
  end

  def instance_id
    (platform_context.present? ? platform_context.instance.id : instance_id_nil)
  end

  def instance_id_nil
    'universal'
  end

  def exists?
    versions_generated?
  end

  def versions_generated?
    model["#{mounted_as}_versions_generated_at"].present?
  end

  def current_url(version = nil, *args)
    if exists? || !source_url
      version = :transformed if version.blank? && self.respond_to?(:transformation_data)
      args.unshift(version) if version && version != :original
      self.url(*args)
    elsif source_url
      #  see https://developers.inkfilepicker.com/docs/web/#convert
      if version && dimensions[version]
        source_url + "/convert?" + { :w => dimensions[version][:width], :h => dimensions[version][:height], :fit => 'crop' }.to_query
      else
        source_url
      end
    end
  end

  def source_url
    model["#{mounted_as}_original_url"].presence
  end

  def self.version(name, options = {}, &block)
    if options[:if] == :delayed_processing?
      @@delayed_versions ||= []
      @@delayed_versions << name
    end
    super
  end

  def delayed_processing?(image = nil)
    !!@delayed_processing
  end
end
