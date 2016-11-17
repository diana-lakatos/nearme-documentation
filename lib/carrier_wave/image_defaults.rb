# frozen_string_literal: true
module CarrierWave
  module ImageDefaults
    extend ActiveSupport::Concern

    included do
      include CarrierWave::MiniMagick
      include CarrierWave::Optimizable

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
    end
  end
end
