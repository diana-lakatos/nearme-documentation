class InstanceTheme < ActiveRecord::Base
  COLORS = %w(blue red orange green gray black white)
  COLORS.each do |color|
    attr_accessible "color_#{color}"
  end

  attr_accessible :name, :icon_image, :icon_retina_image,
    :logo_image, :logo_retina_image, :hero_image, :skip_compilation

  # TODO: We may want the ability to have multiple themes, and draft states,
  #       etc.
  belongs_to :instance

  mount_uploader :icon_image, InstanceThemeImageUploader
  mount_uploader :icon_retina_image, InstanceThemeImageUploader
  mount_uploader :logo_image, InstanceThemeImageUploader
  mount_uploader :logo_retina_image, InstanceThemeImageUploader
  mount_uploader :hero_image, InstanceThemeImageUploader
  mount_uploader :compiled_stylesheet, InstanceThemeStylesheetUploader

  # Precompile the theme, unless we're saving the compiled stylesheet.
  after_save :recompile_theme, :if => :theme_changed?

  # If true, will skip compiling the theme when saving
  attr_accessor :skip_compilation

  def recompile_theme
    CompileInstanceThemeJob.perform(self) unless skip_compilation
  end

  # Checks if any of options that impact the theme stylesheet have been changed.
  def theme_changed?
    attrs = attributes.keys - %w(updated_at compiled_stylesheet name)
    attrs.any? { |attr|
      send("#{attr}_changed?")
    }
  end

  def skipping_compilation(&blk)
    begin
      before, self.skip_compilation = self.skip_compilation, true
      yield(self)
    ensure
      self.skip_compilation = before
    end
    self
  end

end

