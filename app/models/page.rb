# frozen_string_literal: true
require 'rdiscount'

class Page < ActiveRecord::Base
  VALID_LAYOUTS = %w(community application dashboard).freeze
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid
  has_paper_trail
  class NotFound < ActiveRecord::RecordNotFound; end

  include RankedModel
  ranks :position, with_same: :theme_id

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :scoped], scope: :theme

  validates :slug, uniqueness: { scope: :theme_id }
  validates :layout_name, inclusion: { in: VALID_LAYOUTS, allow_blank: true }

  # FIXME: disabled Sitemap updates. Needs to be optimized.
  # include SitemapService::Callbacks

  mount_uploader :hero_image, HeroImageUploader
  skip_callback :commit, :after, :remove_hero_image!

  belongs_to :theme
  belongs_to :instance

  default_scope -> { rank(:position) }

  before_save :convert_to_html, if: ->(page) { page.content.present? && (page.content_changed? || page.html_content.blank?) }

  has_many :data_sources, as: :data_sourcable
  has_many :page_data_source_contents, dependent: :destroy

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

  private

  def convert_to_html
    self.html_content = content.include?('<div') ? content : RDiscount.new(content).to_html
  end

  def should_generate_new_friendly_id?
    !slug.present?
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
