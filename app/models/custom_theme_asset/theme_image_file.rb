# frozen_string_literal: true
class CustomThemeAsset::ThemeImageFile < CustomThemeAsset
  store :settings, accessors: %i(height width)

  validates :file, presence: true

  def asset_type
    'image'
  end
end
