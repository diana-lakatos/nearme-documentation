module CarrierWave
  module Optimizable
    extend ActiveSupport::Concern

    included do
      include CarrierWave::ImageOptim

      version :optimized do
        process optimize: [{
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
          jpegoptim: { allow_lossy: true, max_quality: 70 },
          optipng: { level: 6 }
        }]
      end
    end
  end
end
