class Theme < ActiveRecord::Base
  DEFAULT_EMAIL = 'support@desksnear.me'
  COLORS = %w(blue red orange green gray black white)
  COLORS_DEFAULT_VALUES = %w(#024fa3 #e83d33 #FF8D00 #157A49 #394449 #1e2222 #fafafa)
  COLORS.each do |color|
    attr_accessible "color_#{color}"
  end

  attr_accessible :name, :icon_image, :icon_retina_image,
    :logo_image, :logo_retina_image, :hero_image, :skip_compilation,
    :owner, :owner_id, :owner_type, :site_name, :description, :tagline, :address, :support_email,
    :contact_email, :phone_number, :support_url, :blog_url, :twitter_url, :facebook_url,
    :meta_title

  # TODO: We may want the ability to have multiple themes, and draft states,
  #       etc.
  belongs_to :owner, :polymorphic => true
  delegate :bookable_noun, :to => :instance

  mount_uploader :icon_image, ThemeImageUploader
  mount_uploader :icon_retina_image, ThemeImageUploader
  mount_uploader :logo_image, ThemeImageUploader
  mount_uploader :logo_retina_image, ThemeImageUploader
  mount_uploader :hero_image, ThemeImageUploader
  mount_uploader :compiled_stylesheet, ThemeStylesheetUploader

  # Precompile the theme, unless we're saving the compiled stylesheet.
  after_save :recompile_theme, :if => :theme_changed?

  # Validations
  COLORS.each do |color|
    validates "color_#{color}".to_sym, :hex_color => true, :allow_blank => true
  end
  
  # If true, will skip compiling the theme when saving
  attr_accessor :skip_compilation

  def recompile_theme
    CompileThemeJob.perform(self) unless skip_compilation
  end

  def default_mailer
    EmailTemplate.new(bcc: contact_email,
                      from: contact_email,
                      reply_to: contact_email)
  end

  def contact_email
    read_attribute(:contact_email) || DEFAULT_EMAIL
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

  def is_desksnearme?
    self.id == 1
  end

  def instance
    @instance ||= begin
      case owner_type
      when "Instance"
        owner
      when "Company"
        owner.instance
      else
        raise "Unknown owner #{owner_type}"
      end
    end
  end

end

