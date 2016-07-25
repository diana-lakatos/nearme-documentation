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
    img.nil? ? [] : [img[0], img[1]]
  end

  def proper_file_path
    img_path = self.respond_to?(:current_url) ? current_url(:original) : self.url
    img_path[0] == '/' ? Rails.root.join('public', img_path[1..-1]) : img_path
  end

  def image
    # if MiniMagick opens file then CW does not clear the tmp dir, so identify call
    `identify -format "%[fx:w]x%[fx:h]" #{Rails.root.join('public', file.path)}`.split('x')
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

  def versions_generated?
    model["#{mounted_as}_versions_generated_at"].present?
  end

  def url(*args)
    super_url = super
    if versions_generated? && super_url !~ /\?v=\d+$/
      # We use v=number to trigger CloudFront cache invalidation
      # We add 10 minutes because versions_generated_at is slightly in the past as to
      # our requirements
      "#{super_url}?v=#{model["#{mounted_as}_versions_generated_at"].to_i + 10.minutes.to_i}"
    # Versions not generated, we have a default url and the version requested is a delayed version, so we use the default_url
    elsif !versions_generated? && respond_to?(:default_url) && self.class.respond_to?(:delayed_versions) && self.class.delayed_versions.include?(args.first)
      default_url(*args)
    else
      super_url
    end
  end

  def current_url(version = nil, *args)
    if versions_generated? || !source_url
      if (version.blank? && self.respond_to?(:transformation_data)) \
      || (self.class.respond_to?(:delayed_versions) && self.class.delayed_versions.include?(version) && !versions_generated?)
        version = :transformed
      end
      args.unshift(version) if version && version != :original
      url(*args)
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
    if [:delayed_processing?, :generate_transactable_versions?, :generate_project_versions?].include?(options[:if])
      @@delayed_versions ||= []
      @@delayed_versions << name
    end
    super
  end

  def delayed_processing?(image = nil)
    !!@delayed_processing
  end
end
