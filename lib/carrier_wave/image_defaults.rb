module CarrierWave
  module ImageDefaults
    extend ActiveSupport::Concern

    included do
      include CarrierWave::MiniMagick
      cattr_reader :delayed_versions
      process :auto_orient

      def auto_orient
        manipulate! do |img|
          img.auto_orient
          img
        end
      end

      # Add a white list of extensions which are allowed to be uploaded.
      # For images you might use something like this:
      def extension_white_list
        ['jpg', 'jpeg', 'png', 'gif', 'ico', '']
      end

      # Offers a placeholder while image is not uploaded yet
      def default_url(*args)
        default_image, version = get_default_image_and_version(*args)

        if default_image.blank? || self.class == DefaultImageUploader
          default_placeholder(version)
        else
          default_image.photo_uploader_image.url(:transformed)
        end
      end

      def default_placeholder(version)
        dimensions = version && self.class.dimensions.key?(version) ? self.class.dimensions[version] : { width: 100, height: 100 }
        Placeholder.new(dimensions).path
      end
    end
  end
end
