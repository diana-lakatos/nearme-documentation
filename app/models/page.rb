class Page < ActiveRecord::Base
  mount_uploader :hero_image, HeroImageUploader

  belongs_to :theme

end
