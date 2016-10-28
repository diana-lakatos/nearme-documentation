module CarrierWave
  module Optimizable
    extend ActiveSupport::Concern
    OPTIMIZE_SETTINGS = [{
      skip_missing_workers: true,
      advpng: false,
      gifsicle: true,
      jhead: false,
      jpegrecompress: true,
      jpegtran: false,
      pngcrush: false,
      pngout: false,
      pngquant: true,
      svgo: false,
      jpegoptim: { allow_lossy: true, max_quality: 75 },
      optipng: { level: 6 }
    }].freeze

    included do
      include CarrierWave::ImageOptim

      version :optimized, if: :delayed_processing? do
        process optimize: OPTIMIZE_SETTINGS
      end
    end
  end
end
