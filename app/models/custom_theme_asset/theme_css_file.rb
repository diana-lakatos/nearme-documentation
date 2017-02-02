class CustomThemeAsset::ThemeCssFile < CustomThemeAsset
  store :settings, accessors: %i(gzip)
  validates_presence_of :body, if: -> (cta) { cta.file.blank? }

  def supports_body?
    true
  end

  def asset_type
    'css'
  end
end
