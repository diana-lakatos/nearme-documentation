class BlogInstance < ActiveRecord::Base

  # attr_accessible :enabled, :name, :header, :facebook_app_id,
  #                 :header_text, :header_motto, :header_logo, :header_icon

  mount_uploader :header, HeroImageUploader
  mount_uploader :header_logo, HeroImageUploader
  mount_uploader :header_icon, HeroImageUploader

  has_many :blog_posts
  belongs_to :owner, polymorphic: true

  def is_near_me?
    self.owner_type == 'near-me'
  end

end
