# frozen_string_literal: true
class DefaultPhoto
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
    def url(version:, uploader_klass:)
      version = version.to_sym
      if PlatformContext.current
        PlatformContext.current.default_photo_url(version: version, uploader_klass: uploader_klass)
      else
        default_photo(version: version, uploader_klass: uploader_klass)
      end
    end

    def default_photo(version:, uploader_klass:)
      uploader_klass.default_placeholder(version)
    end
  end

  def initialize
    @cache = VersionCache.new
  end

  def url(version:, uploader_klass:)
    @cache.fetch(version: version, uploader_klass: uploader_klass) do
      image = default_image(version: version, uploader_klass: uploader_klass)
      if image.present?
        image.photo_uploader_image.url(version)
      else
        self.class.default_photo(version: version, uploader_klass: uploader_klass)
      end
    end
  end

  protected

  def default_image(version:, uploader_klass:)
    PlatformContext.current.theme.default_images.where(photo_uploader: uploader_klass.name,
                                                       photo_uploader_version: version).first
  end
end
