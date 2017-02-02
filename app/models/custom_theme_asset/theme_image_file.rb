class CustomThemeAsset::ThemeImageFile < CustomThemeAsset
  store :settings, accessors: %i(height width)

  validates_presence_of :file

  def asset_type
    'image'
  end
end
