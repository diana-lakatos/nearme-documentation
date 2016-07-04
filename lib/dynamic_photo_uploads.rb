module DynamicPhotoUploads
  extend ActiveSupport::Concern

  included do

    def dynamic_version(version)
      override = PlatformContext.current.theme.photo_upload_versions.where(version_name: version, photo_uploader: self.class.parent.to_s).first
      if override.present?
        self.send(override.apply_transform, override.width, override.height)
      else
        self.send(self.class.dimensions[version][:transform], self.class.dimensions[version][:width], self.class.dimensions[version][:height])
      end
    end

  end

end
