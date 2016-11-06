class PhotoUploadVersionFetcher
  def initialize
    @photo_upload_versions_cache = {}
  end

  def dimensions(version, uploader)
    # search for custom photo_upload_version
    override = fetch(version, uploader)
    return { width: override.width, height: override.height } if override

    # search for predefined version sizes
    return uploader.dimensions[version] if version && uploader.dimensions.key?(version)

    # catch all default
    { width: 100, height: 100 }
  end

  private

  def fetch(version, uploader)
    key = "#{version}-#{uploader}"
    @photo_upload_versions_cache[key] ||= find_version(version, uploader)
    @photo_upload_versions_cache[key]
  end

  def find_version(version, uploader)
    PlatformContext.current.theme.photo_upload_versions
                   .where(version_name: version, photo_uploader: uploader).first
  end
end
