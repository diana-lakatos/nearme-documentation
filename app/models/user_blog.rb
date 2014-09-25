class UserBlog < ActiveRecord::Base
  class NotFound < ActiveRecord::RecordNotFound; end

  belongs_to :user

  validates :name, presence: true, if: lambda { |o| o.enabled? }

  mount_uploader :header_image, BaseImageUploader
  mount_uploader :header_logo, BaseImageUploader
  mount_uploader :header_icon, BaseImageUploader

  def test_enabled
    enabled? ? self : (raise NotFound)
  end
end
