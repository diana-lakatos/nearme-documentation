class Locale < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  # Generates /^\/(aa|ab|af|ak|sq|am|ar|an|hy|as|...|zu)(?=\/|$)/
  DOMAIN_PATTERN = %r{^/(#{I18n::LanguagesWrapper.language_codes.join('|')})(?=/|$)}

  belongs_to :instance, touch: true
  has_many :locale_instance_views, dependent: :destroy
  has_many :instance_views, through: :locale_instance_views

  validates_presence_of :code, :instance_id
  validates_uniqueness_of :code, scope: :instance_id

  before_save :remove_primary

  before_destroy :check_locale
  after_destroy :delete_instance_keys
  after_destroy :check_user_settings
  after_create :create_tranlsation_keys_for_categories

  include Cacheable

  scope :by_created_at, -> { order('created_at ASC') }

  def self.remove_locale_from_url(url)
    url.sub!(DOMAIN_PATTERN) { Regexp.last_match(2) || '' }
    url.replace('/') if url.empty?
    url
  end

  def self.change_locale_in_url(url, new_locale)
    url.sub!(DOMAIN_PATTERN) { Regexp.last_match(2) || "/#{new_locale}" }
    if url == '/'
      url.sub!('/', "/#{new_locale}")
    else
      url = "/#{new_locale}" + url unless url =~ DOMAIN_PATTERN
    end
    url
  end

  def self.primary
    find_by primary: true
  end

  def self.default_locale
    find_by(primary: true).try(:code).try(:to_sym)
  end

  def self.find_by_code(code)
    Rails.cache.fetch("locale.find_by_code_#{code}_#{PlatformContext.current.instance.cache_key}") do
      find_by(code: code)
    end
  end

  def self.available_locales
    pluck(:code).map(&:to_sym)
  end

  def name
    I18n::LanguagesWrapper.language_name(code)
  end

  def display_name
    custom_name.blank? ? name : custom_name
  end

  def expire_cache_options
    { with_defaults: true }
  end

  private

  def create_tranlsation_keys_for_categories
    Category.find_each(&:create_translation_key)
  end

  def remove_primary
    self.class.where(primary: true).where.not(id: id).update_all primary: false if primary?
  end

  def check_locale
    if primary?
      errors[:base] << "You can't delete default locale"
      return false
    end
  end

  def delete_instance_keys
    Translation.for_instance(instance_id).where(locale: code).delete_all
  end

  def check_user_settings
    instance.users.where(language: code).update_all(language: instance.primary_locale)
  end
end
