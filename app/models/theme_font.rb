class ThemeFont < ActiveRecord::Base
  FONT_TYPES = %w(regular medium bold)
  FONT_EXTENSIONS = %w(eot ttf svg woff)

  belongs_to :theme, touch: true
  delegate :instance, to: :theme

  mount_uploader :bold_eot, ThemeFontUploader
  mount_uploader :bold_svg, ThemeFontUploader
  mount_uploader :bold_ttf, ThemeFontUploader
  mount_uploader :bold_woff, ThemeFontUploader
  mount_uploader :medium_eot, ThemeFontUploader
  mount_uploader :medium_svg, ThemeFontUploader
  mount_uploader :medium_ttf, ThemeFontUploader
  mount_uploader :medium_woff, ThemeFontUploader
  mount_uploader :regular_eot, ThemeFontUploader
  mount_uploader :regular_svg, ThemeFontUploader
  mount_uploader :regular_ttf, ThemeFontUploader
  mount_uploader :regular_woff, ThemeFontUploader

  ThemeFont::FONT_TYPES.map do |font_type|
    ThemeFont::FONT_EXTENSIONS.map do |font_extension|
      validates_presence_of "#{font_type}_#{font_extension}"
    end
  end

  def theme_font_changed?
    attrs = attributes.keys - %w(updated_at)
    attrs.any? do |attr|
      send("#{attr}_changed?")
    end
  end
end
