# frozen_string_literal: true
class BaseUploader < CarrierWave::Uploader::Base
  def proper_file_path
    img_path = url
    img_path[0] == '/' ? Rails.root.join('public', img_path[1..-1]) : img_path
  end

  # TODO: move existing files from non images to different path and update this method
  def store_dir
    "#{instance_prefix}/uploads/images/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def platform_context
    PlatformContext.current
  end

  def instance_prefix
    raise NotImplementedError, 'PlatformContext must be present to upload to s3' if instance_id.nil?
    "instances/#{instance_id}"
  end

  def instance_id
    model.try(:instance_id) || platform_context.instance.id
  end
end
