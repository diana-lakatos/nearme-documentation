class UserBlog < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  class NotFound < ActiveRecord::RecordNotFound; end

  belongs_to :user
  belongs_to :instance

  validates :name, presence: true, if: lambda { |o| o.enabled? }

  mount_uploader :header_logo, BaseImageUploader
  mount_uploader :header_icon, BaseImageUploader

  def test_enabled
    enabled? ? self : (raise NotFound)
  end
end
