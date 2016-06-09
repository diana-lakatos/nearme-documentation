class CustomThemeAsset < ActiveRecord::Base
  self.inheritance_column = :type
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :custom_theme

  mount_uploader :file, CustomThemeAssetUploader

  scope :css_files, -> { where(type: 'CustomThemeAsset::ThemeCssFile') }
  scope :js_files, -> { where(type: 'CustomThemeAsset::ThemeJsFile') }
  scope :image_files, -> { where(type: 'CustomThemeAsset::ThemeImageFile') }
  scope :font_files, -> { where(type: 'CustomThemeAsset::ThemeFontFile') }

  validates_presence_of :name
  validates_uniqueness_of :name, scope: [:instance_id, :custom_theme_id]
  validates_presence_of :type

  before_validation :use_filename_as_name, if: -> (cta) { cta.name.blank? && cta.file.present? }

  def supports_body?
    false
  end

  def use_filename_as_name
    self.name = File.basename(file.proper_file_path)
  end


end

