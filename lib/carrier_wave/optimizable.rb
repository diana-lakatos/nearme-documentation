# frozen_string_literal: true
module CarrierWave
  module Optimizable
    extend ActiveSupport::Concern
    OPTIMIZE_SETTINGS = {
      skip_missing_workers: true,
      advpng: false,
      gifsicle: true,
      jhead: false,
      jpegrecompress: true,
      jpegtran: false,
      pngcrush: false,
      pngout: false,
      pngquant: false,
      svgo: false,
      jpegoptim: { allow_lossy: true, max_quality: 85 },
      optipng: { level: 2 }
    }.freeze

    included do
      include CarrierWave::ImageOptim
    end
  end
end
