class Page < ActiveRecord::Base
  class NotFound < ActiveRecord::RecordNotFound; end

  include RankedModel
  ranks :position, with_same: :theme_id

  extend FriendlyId
  friendly_id :path, use: :slugged

  mount_uploader :hero_image, HeroImageUploader

  belongs_to :theme

  default_scope -> { rank(:position) }

  def to_liquid
    PageDrop.new(self)
  end

end
