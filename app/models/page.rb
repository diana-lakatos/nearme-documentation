class Page < ActiveRecord::Base
  class NotFound < ActiveRecord::RecordNotFound; end
  extend FriendlyId
  friendly_id :path, use: :slugged

  mount_uploader :hero_image, HeroImageUploader

  belongs_to :theme

  def to_liquid
    PageDrop.new(self)
  end

end
