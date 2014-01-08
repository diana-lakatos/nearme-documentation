class Page < ActiveRecord::Base
  class NotFound < ActiveRecord::RecordNotFound; end

  include RankedModel
  ranks :position, with_same: :theme_id

  extend FriendlyId
  friendly_id :path, use: :slugged

  mount_uploader :hero_image, HeroImageUploader

  belongs_to :theme

  default_scope -> { rank(:position) }

  before_save :convert_to_html

  def to_liquid
    PageDrop.new(self)
  end

  private 

  def convert_to_html
    if content.present?
      self.html_content = RDiscount.new(self.content).to_html
      rel_no_follow_adder = RelNoFollowAdder.new({:skip_domains => Domain.pluck(:name)})
      self.html_content = rel_no_follow_adder.modify(self.html_content)
    end
  end

end
