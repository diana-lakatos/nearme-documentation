# frozen_string_literal: true
module CarrierWave
  module DynamicPhotoUploads
    extend ActiveSupport::Concern

    included do
      def dynamic_version(version)
        dimensions = PhotoUploadVersionFetcher.dimensions(version: version, uploader_klass: self.class.parent)
        send(dimensions[:transform], dimensions[:width], dimensions[:height])
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
