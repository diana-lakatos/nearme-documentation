class Page < ActiveRecord::Base
  acts_as_paranoid
  class NotFound < ActiveRecord::RecordNotFound; end

  include RankedModel
  ranks :position, with_same: :theme_id

  extend FriendlyId
  friendly_id :path, use: :slugged

  mount_uploader :hero_image, HeroImageUploader
  skip_callback :commit, :after, :remove_hero_image!

  belongs_to :theme

  default_scope -> { rank(:position) }

  before_save :convert_to_html, :if => lambda { |page| page.content.present? && (page.content_changed? || page.html_content.blank?) }

  def to_liquid
    PageDrop.new(self)
  end

  def redirect?
    redirect_url.present?
  end

  private 

  def convert_to_html
    self.html_content = RDiscount.new(self.content).to_html
    rel_no_follow_adder = RelNoFollowAdder.new({:skip_domains => Domain.pluck(:name)})
    self.html_content = rel_no_follow_adder.modify(self.html_content)
  end

end
