# frozen_string_literal: true
class CustomThemeAsset::ThemeCssFile < CustomThemeAsset
  store :settings, accessors: %i(gzip)
  validates :body, presence: { if: ->(cta) { cta.file.blank? } }

  def supports_body?
    true
  end

  def asset_type
    'css'
  end
end
