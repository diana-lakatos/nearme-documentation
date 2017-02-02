class CustomThemeAsset::ThemeFile < CustomThemeAsset
  validates_presence_of :file

  def asset_type
    'other'
  end
end
