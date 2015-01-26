class BlogInstance < ActiveRecord::Base

  mount_uploader :header, HeroImageUploader
  mount_uploader :header_logo, HeroImageUploader
  mount_uploader :header_icon, HeroImageUploader

  has_many :blog_posts
  belongs_to :owner, polymorphic: true

  accepts_nested_attributes_for :owner

  def is_near_me?
    self.owner_type == 'near-me'
  end

  def instance
    Instance === owner ? owner : nil
  end

end
