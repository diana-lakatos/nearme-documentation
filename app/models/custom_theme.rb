class CustomTheme < ActiveRecord::Base
  include DomainsCacheable
  auto_set_platform_context
  acts_as_paranoid

  belongs_to :themeable, polymorphic: true
  belongs_to :instance

  has_many :instance_views
  has_many :custom_theme_assets

  attr_accessor :update_in_use, :copy_from_template, :overwrite_existing

  validates_presence_of :name

  before_create { self.overwrite_existing = "1" }

  after_save :mark_as_in_use, if: -> (ct) { ct.in_use_changed? }
  after_save :recalculate_instance_cache_key, if: -> (ct) { ct.in_use_changed? && ct.in_use? }
  after_save :copy_default_template_files, if: -> (ct) { ct.copy_from_template.present? && AVAILABLE_DEFAULT_TEMPLATES.map(&:last).include?(ct.copy_from_template) && ct.overwrite_existing == '1' }

  AVAILABLE_DEFAULT_TEMPLATES = [['NearMe -> Community', 'nearme/community']].freeze

  protected

  def mark_as_in_use
    instance.custom_themes.where('id != ?', id).update_all(in_use: false)
  end

  def copy_default_template_files
    Utils::CustomTemplateLoader.new(self, File.join(Rails.root, 'app', 'default_templates', copy_from_template)).load!
  end

  def recalculate_instance_cache_key
    self.instance.recalculate_cache_key!
  end

end

