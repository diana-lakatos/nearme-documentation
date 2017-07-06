# frozen_string_literal: true
class Page < ActiveRecord::Base
  include RankedModel
  extend FriendlyId
  DEFAULT_FORMAT = 'html'
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid
  has_paper_trail
  class NotFound < ActiveRecord::RecordNotFound; end

  belongs_to :instance
  belongs_to :theme
  has_many :authorization_policies, through: :authorization_policy_associations
  has_many :authorization_policy_associations, as: :authorizable, dependent: :destroy
  has_many :data_sources, as: :data_sourcable
  has_many :page_data_source_contents, dependent: :destroy

  validates :slug, uniqueness: { scope: [:theme_id, :format] }

  default_scope -> { rank(:position) }
  scope :admin_pages, -> { where(admin_page: true) }

  before_save :convert_to_html, if: ->(page) { page.content.present? && (page.content_changed? || page.html_content.blank?) }

  enum format: { html: 0, json: 1 }
  mount_uploader :hero_image, HeroImageUploader
  skip_callback :commit, :after, :remove_hero_image!
  ranks :position, with_same: :theme_id
  friendly_id :slug_candidates, use: [:slugged, :finders, :scoped], scope: :theme
  # FIXME: disabled Sitemap updates. Needs to be optimized.
  # include SitemapService::Callbacks

  def to_liquid
    @page_drop ||= PageDrop.new(self)
  end

  def redirect?
    redirect_url.present?
  end

  def redirect_url_in_known_domain?
    is_http_https = (redirect_url.downcase =~ /^http|^https/)
    (is_http_https && Domain.pluck(:name).any? { |d| redirect_url.include?(d) }) || !is_http_https
  end

  def self.possible_slugs(slug, format)
    [slug, "#{slug}.#{format}"]
  end

  def self.redirect_statuses
    {
      '301 - Moved Permanently' => 301,
      '302 - Found' => 302,
      '307 - Temporary Redirect' => 307
    }
  end

  def valid_page_layouts
    all_layouts = Page::VALID_LAYOUTS.dup
    all_layouts.delete('community') if instance && !instance.is_community?
    all_layouts
  end

  private

  # TODO: get rid of markdown content from page and convert everything into html
  def convert_to_html
    self.html_content = render_markdown? ? MarkdownWrapper.new(content).to_html : content
  end

  def render_markdown?
    !html_content? && !json?
  end

  # we could explicity choose content type for a page(ex. markdown, html) and use proper renderer
  def html_content?
    content.match(/<(br|basefont|hr|input|source|frame|param|area|meta|a|abbr|acronym|address|applet|article|aside|audio|b|bdi|bdo|big|blockquote|body|button|canvas|caption|center|cite|code|colgroup|command|datalist|dd|del|details|dfn|dialog|dir|div|dl|dt|em|embed|fieldset|figcaption|figure|font|footer|form|frameset|head|header|hgroup|h1|h2|h3|h4|h5|h6|html|i|iframe|ins|kbd|keygen|label|legend|li|map|mark|menu|meter|nav|noframes|noscript|object|ol|optgroup|output|p|pre|progress|q|rp|rt|ruby|s|samp|script|section|select|small|span|strike|strong|style|sub|summary|sup|table|tbody|td|textarea|tfoot|th|thead|time|title|tr|track|tt|u|ul|var|video).*/)
  end

  def should_generate_new_friendly_id?
    !slug.present?
  end

  def forms_hash
    @forms_hash ||= form_configurations.each_with_object({}) do |form, hash|
      hash[form.name] = form
    end
  end

  def slug_candidates
    [
      :slug,
      :path,
      [:path, self.class.last.try(:id).to_i + 1],
      [:path, rand(1_000_000)]
    ]
  end
end
