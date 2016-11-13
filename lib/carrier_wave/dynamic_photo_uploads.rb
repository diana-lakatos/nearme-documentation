# frozen_string_literal: true
module CarrierWave
  module DynamicPhotoUploads
    extend ActiveSupport::Concern

    included do
      def dynamic_version(version)
        override = PlatformContext.current.theme.photo_upload_versions
                                  .where(version_name: version, photo_uploader: self.class.parent.to_s)
                                  .select(:apply_transform, :width, :height).first
        if override.present?
          send(override.apply_transform, override.width, override.height)
        else
          send(self.class.dimensions[version][:transform],
               self.class.dimensions[version][:width],
               self.class.dimensions[version][:height])
        end
        # i tried splitting dynamic_version and optimize but there is
        # an issue with ordering methods -> as the end result we first optimize
        # original image (which takes a lot of time) and then we make smaller version.
        # By moving this method here, we guarantee the order will be correct.
        # Morever, we only want to invoke this in the background.
        # model.send(mounted_as) is necessary hack for some reason.
        optimize(CarrierWave::Optimizable::OPTIMIZE_SETTINGS) if model.send(mounted_as).delayed_processing
      end
    end
  end
end
