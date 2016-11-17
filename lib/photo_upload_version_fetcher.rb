# frozen_string_literal: true
class PhotoUploadVersionFetcher
  DEFAULT_DIMENSIONS = { transform: :resize_to_fill, width: 100, height: 100 }.freeze
  class VersionCache
    def initialize
      @cache = {}
    end

    def fetch(version:, uploader_klass:)
      @cache[uploader_klass] ||= {}
      @cache[uploader_klass][version] ||= yield
    end
  end

  class << self
    def dimensions(version:, uploader_klass:)
      version = version&.to_sym
      if PlatformContext.current.present?
        PlatformContext.current.photo_upload_version_dimensions(version: version, uploader_klass: uploader_klass)
      else
        default_dimensions(version: version, uploader_klass: uploader_klass)
      end
    end

    def default_dimensions(version:, uploader_klass:)
      if version && uploader_klass&.dimensions&.key?(version)
        uploader_klass.dimensions[version]
      else
        DEFAULT_DIMENSIONS
      end
    end
  end

  def initialize
    @cache = VersionCache.new
  end

  def dimensions(version:, uploader_klass:)
    @cache.fetch(version: version, uploader_klass: uploader_klass) do
      override = photo_uploader_version(version: version,
                                        uploader_klass: uploader_klass)
      if override
        { transform: override.apply_transform, width: override.width, height: override.height }
      else
        self.class.default_dimensions(version: version, uploader_klass: uploader_klass)
      end
    end
  end

  protected

  def photo_uploader_version(version:, uploader_klass:)
    PlatformContext.current.theme.photo_upload_versions.where(version_name: version,
                                                              photo_uploader: uploader_klass&.name).first
  end
end
