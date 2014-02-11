class BlogInstance < ActiveRecord::Base

  attr_accessible :enabled, :name, :header, :facebook_app_id

  mount_uploader :header, HeroImageUploader

  has_many :blog_posts
  belongs_to :owner, polymorphic: true

end
