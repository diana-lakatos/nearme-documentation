class CustomThemeAsset::ThemeImageFile < CustomThemeAsset
  store :settings, accessors: %i(height width)

  validates_presence_of :file
end
