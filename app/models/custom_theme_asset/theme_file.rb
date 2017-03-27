# frozen_string_literal: true
class CustomThemeAsset::ThemeFile < CustomThemeAsset
  validates :file, presence: true

  def asset_type
    'other'
  end
end
