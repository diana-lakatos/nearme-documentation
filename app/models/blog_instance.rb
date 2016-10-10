class BlogInstance < ActiveRecord::Base
  mount_uploader :header, HeroImageUploader
  mount_uploader :header_logo, HeroImageUploader
  mount_uploader :header_icon, HeroImageUploader

  has_many :blog_posts
  belongs_to :owner, polymorphic: true
  belongs_to :instance, primary_key: 'owner_id'

  has_many :user_blog_posts, foreign_key: 'instance_id', primary_key: 'owner_id'

  accepts_nested_attributes_for :owner

  def is_near_me?
    owner_type == 'near-me'
  end

  def instance
    Instance === owner ? owner : nil
  end

  def meta_description
    [name, header_text, header_motto].reject(&:blank?).join(' - ')
  end

  def to_liquid
    @blog_instance_drop ||= BlogInstanceDrop.new(self)
  end
end
