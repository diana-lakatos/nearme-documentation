class CustomThemeAssetUploader < BaseUploader

  def store_dir
    "#{instance_prefix}/custom_themes/#{model.custom_theme.id}/#{model.class.to_s.demodulize.underscore}"
  end

end

