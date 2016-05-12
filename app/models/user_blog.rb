class UserBlog < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  class NotFound < ActiveRecord::RecordNotFound; end

  belongs_to :user
  belongs_to :instance

  validates :name, presence: true, if: lambda { |o| o.enabled? }

  mount_uploader :header_logo, BaseImageUploader
  mount_uploader :header_icon, BaseImageUploader
  mount_uploader :header_image, BaseImageUploader

  def test_enabled
    raise NotFound unless instance.blogging_enabled?(user)
    raise NotFound unless enabled?
    self
  end

  def to_liquid
    @user_blog_drop ||= UserBlogDrop.new(self)
  end

end
