class Page < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid
  has_paper_trail
  class NotFound < ActiveRecord::RecordNotFound; end

  include RankedModel
  ranks :position, with_same: :theme_id

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :scoped], scope: :theme

  include SitemapService::Callbacks

  mount_uploader :hero_image, HeroImageUploader
  skip_callback :commit, :after, :remove_hero_image!

  belongs_to :theme
  belongs_to :instance

  default_scope -> { rank(:position) }

  before_save :convert_to_html, :if => lambda { |page| page.content.present? && (page.content_changed? || page.html_content.blank?) }

  def to_liquid
    @page_drop ||= PageDrop.new(self)
  end

  def redirect?
    redirect_url.present?
  end

  def redirect_url_in_known_domain?
    is_http_https = (redirect_url.downcase =~ /^http|^https/)
    (is_http_https && Domain.pluck(:name).any?{|d| self.redirect_url.include?(d)}) || !is_http_https
  end

  def normalize_friendly_id(value)
    sep = "-"
    if value.include?(".")
      self.extension = value.split(".").last
      value = value.split(".").first
    end

    parameterized_string = ActiveSupport::Inflector.transliterate(value)
    parameterized_string.gsub!(/[^a-z0-9\-_]+/, sep)
    re_sep = Regexp.escape(sep)
    parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
    parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/, '')
    parameterized_string.downcase
  end

  private

  def convert_to_html
    self.html_content = RDiscount.new(self.content).to_html
    rel_no_follow_adder = RelNoFollowAdder.new({:skip_domains => Domain.pluck(:name)})
    self.html_content = rel_no_follow_adder.modify(self.html_content)
  end

  def should_generate_new_friendly_id?
    return false if slug.present?
    path_changed? || slug_changed?
  end

  def slug_candidates
    [
      :slug,
      :path,
      [:path, DateTime.now.strftime("%b %d %Y")]
    ]
  end
end
