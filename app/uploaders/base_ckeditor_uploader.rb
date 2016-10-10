# encoding: utf-8
class BaseCkeditorUploader < BaseUploader
  include Ckeditor::Backend::CarrierWave

  def fog_public
    !Ckeditor::Asset::GLOBAL_ASSET_ACCESS_LEVELS.include?(model.access_level)
  end

  def store_dir
    "#{instance_prefix}/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def legacy_store_dir
    "uploads/#{platform_context.instance.id}/ckeditor/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
