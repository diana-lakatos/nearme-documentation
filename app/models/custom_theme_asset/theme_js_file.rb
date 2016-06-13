class CustomThemeAsset::ThemeJsFile < CustomThemeAsset
  store :settings, accessors: %i(gzip)
  validates_presence_of :body, if: -> (cta) { cta.file.blank? }

  def supports_body?
    true
  end
end

