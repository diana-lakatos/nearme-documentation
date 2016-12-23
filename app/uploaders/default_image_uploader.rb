# frozen_string_literal: true
class DefaultImageUploader < BaseUploader
  include CarrierWave::ImageDefaults
  version :transformed do
    process transformed_version: :transformed
  end

  def transformed_version(version)
    dimensions = PhotoUploadVersionFetcher.dimensions(version: @model.photo_uploader_version, uploader_klass: @model.photo_uploader&.constantize)
    send(dimensions[:transform], dimensions[:width], dimensions[:height])
  end
end
