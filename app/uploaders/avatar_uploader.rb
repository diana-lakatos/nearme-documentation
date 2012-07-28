# encoding: utf-8
class AvatarUploader < BaseUploader

  after :remove, :clear_uploader

  def clear_uploader
    @file = @filename = @original_filename = @cache_id = @version = @storage = nil
    model.send(:write_attribute, mounted_as, nil)
  end


  def store_dir
    "media/#{model.class.to_s.underscore}/#{model.id}/#{mounted_as}"
  end
end
