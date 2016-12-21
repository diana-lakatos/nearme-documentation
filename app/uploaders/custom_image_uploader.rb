# frozen_string_literal: true
# encoding: utf-8
class CustomImageUploader < BaseUploader
  include CarrierWave::TransformableImage
  include CarrierWave::ImageDefaults
  include CarrierWave::Cleanable

  def aspect_ratio
    model.aspect_ratio || 1
  end

  version :mini, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :mini
  end

  version :thumb, from_version: :transformed do
    process dynamic_version: :thumb
  end

  version :normal, from_version: :transformed, if: :delayed_processing? do
    process dynamic_version: :normal
  end

  def dynamic_version(version)
    return unless model.custom_attribute.present?
    send(*model.settings_for_version(version))
    # i tried splitting dynamic_version and optimize but there is
    # an issue with ordering methods -> as the end result we first optimize
    # original image (which takes a lot of time) and then we make smaller version.
    # By moving this method here, we guarantee the order will be correct.
    # Morever, we only want to invoke this in the background.
    # model.send(mounted_as) is necessary hack for some reason.
    optimize(model.optimization_settings) if model.send(mounted_as).delayed_processing
  end

  def store_dir
    "#{instance_prefix}/uploads/images/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
