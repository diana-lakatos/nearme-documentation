# frozen_string_literal: true
module CarrierWave::TransformableImage
  extend ActiveSupport::Concern

  included do
    version :transformed, if: :delayed_processing? do
      process :apply_rotate
      process :apply_crop
    end

    def aspect_ratio
      self.class::ASPECT_RATIO
    end

    def apply_crop
      unless transformation_crop.empty?
        crop = transformation_crop

        manipulate! do |img|
          img.crop "#{crop[:w]}x#{crop[:h]}+#{crop[:x]}+#{crop[:y]}"
          img
        end
      end
    end

    def apply_rotate
      unless transformation_rotate.zero?
        manipulate! do |img|
          img.rotate transformation_rotate.to_s
          img
        end
      end
    end

    def transformation_crop
      transformation_data[:crop] || {}
    end

    def transformation_rotate
      transformation_data[:rotate].try(:to_i) || 0
    end

    def transformation_data
      case data = model["#{mounted_as}_transformation_data"]
      when String
        YAML.load(data)
      else
        data
      end || {}
    end
  end
end
