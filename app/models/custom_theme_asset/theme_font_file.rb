# frozen_string_literal: true
class CustomThemeAsset::ThemeFontFile < CustomThemeAsset
  validates :file, presence: true

  def asset_type
    'font'
  end
end
