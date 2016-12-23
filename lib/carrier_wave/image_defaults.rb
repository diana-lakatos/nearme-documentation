# frozen_string_literal: true
module CarrierWave
  module ImageDefaults
    extend ActiveSupport::Concern

    included do
      include CarrierWave::MiniMagick
      include CarrierWave::Optimizable
      include CarrierWave::MiniMagick

      attr_accessor :delayed_processing

      # Define the dimensions for versions of the uploader in a class attribute
      # that can be accessed by parts of the Uploader stack.
      class_attribute :dimensions
      self.dimensions = {}

      class << self
        def default_placeholder(version)
          Placeholder.new(
            PhotoUploadVersionFetcher.dimensions(version: version, uploader_klass: self)
          ).path
        end
      end

      cattr_reader :delayed_versions
      process :auto_orient

      def auto_orient
        manipulate! { |img| img.tap(&:auto_orient) }
      end

      # Add a white list of extensions which are allowed to be uploaded.
      # For images you might use something like this:
      def extension_white_list
        ['jpg', 'jpeg', 'png', 'gif', 'ico', '']
      end

      # Offers a placeholder while image is not uploaded yet
      def default_url(*args)
        version = args.first
        return '' if version.blank?
        DefaultPhoto.url(version: version, uploader_klass: self.class)
      end

      def versions_generated?
        model["#{mounted_as}_versions_generated_at"].present?
      end

      def url(*args)
        version = args.first
        super_url = super(*args) rescue nil
        if versions_generated? && super_url && super_url !~ /\?v=\d+$/
          # We use v=number to trigger CloudFront cache invalidation
          # We add 10 minutes because versions_generated_at is slightly in the past as to
          # our requirements
          "#{super_url}?v=#{model["#{mounted_as}_versions_generated_at"].to_i + 10.minutes.to_i}"
        elsif super_url.blank? || pending_processing?(version)
          default_url(*args)
        else
          super_url
        end
      end

      def self.version(name, options = {}, &block)
        if [:delayed_processing?].include?(options[:if])
          @@delayed_versions ||= Set.new
          @@delayed_versions.add(name)
        end
        super
      end

      def delayed_processing?(_image = nil)
        !!@delayed_processing
      end

      def pending_processing?(version)
        # Versions not generated, we have a default url and the version requested is a delayed version, so we use the default_url
        !versions_generated? &&
          respond_to?(:default_url) &&
          self.class.respond_to?(:delayed_versions) &&
          self.class.delayed_versions.include?(version)
      end

      # Override the directory where uploaded files will be stored.
      # This is a sensible default for uploaders that are meant to be mounted:
      def store_dir
        "#{instance_prefix}/uploads/images/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end

      def image
        # if MiniMagick opens file then CW does not clear the tmp dir, so identify call
        `identify -format "%[fx:w]x%[fx:h]" #{Rails.root.join('public', file.path)}`.split('x')
      rescue
        nil
      end

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
    end
  end
end
