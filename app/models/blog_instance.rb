class BlogInstance < ActiveRecord::Base

  attr_accessible :name, :header

  mount_uploader :header, HeroImageUploader

  has_many :blog_posts, order: 'created_at desc'
  belongs_to :owner, polymorphic: true

end
