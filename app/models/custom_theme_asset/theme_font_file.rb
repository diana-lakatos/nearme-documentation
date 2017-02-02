class CustomThemeAsset::ThemeFontFile < CustomThemeAsset
  validates_presence_of :file

  def asset_type
    'font'
  end
end
