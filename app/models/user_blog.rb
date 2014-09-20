class UserBlog < ActiveRecord::Base
  belongs_to :user

  validates :name, presence: true, if: lambda { |o| o.enabled? }

  mount_uploader :header_image, BaseImageUploader
  mount_uploader :header_logo, BaseImageUploader
  mount_uploader :header_icon, BaseImageUploader
end
