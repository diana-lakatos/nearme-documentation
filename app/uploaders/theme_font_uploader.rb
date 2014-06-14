class ThemeFontUploader < BaseUploader

  def extension_white_list
    %w(ttf eot woff svg)
  end

  def store_dir
    "#{instance_prefix}/uploads/_system/fonts/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def legacy_store_dir
    super
  end
end

