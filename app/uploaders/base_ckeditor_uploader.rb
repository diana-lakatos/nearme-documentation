# encoding: utf-8
class BaseCkeditorUploader < BaseUploader
  include Ckeditor::Backend::CarrierWave
  
  def store_dir
    "uploads/#{platform_context.instance.id}/ckeditor/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
