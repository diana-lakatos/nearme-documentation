# frozen_string_literal: true
class DefaultImageUploader < BaseUploader
  include CarrierWave::ImageDefaults
  version :transformed do
    process transformed_version: :transformed
  end

  def transformed_version(_version)
    if @model.photo_uploader.present? && @model.photo_uploader_version.present?
      photo_uploader = @model.photo_uploader.constantize
      uploader_version = @model.photo_uploader_version.to_sym

      override = PlatformContext.current.theme.reload.photo_upload_versions
                                .where(version_name: uploader_version, photo_uploader: photo_uploader).first

      if override.blank?
        transformation = photo_uploader.dimensions[uploader_version][:transform]
        width = photo_uploader.dimensions[uploader_version][:width]
        height = photo_uploader.dimensions[uploader_version][:height]
      else
        transformation = override.apply_transform
        width = override.width
        height = override.height
      end

      send(transformation, width, height)
    else
      # This image will be discarded as the model will not be saved; required to be here
      send(:resize_to_fill, 100, 100)
    end
  end
end
