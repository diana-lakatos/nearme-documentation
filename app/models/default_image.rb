class DefaultImage < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  PHOTO_UPLOADERS = %w(PhotoUploader AvatarUploader AuthorAvatarUploader GroupCoverImageUploader LinkImageUploader SimpleAvatarUploader TopicCoverImageUploader TopicImageUploader CoverImageUploader)

  belongs_to :theme

  mount_uploader :photo_uploader_image, DefaultImageUploader

  validates_uniqueness_of :photo_uploader, scope: [:instance_id, :theme_id, :photo_uploader_version]
  validates_inclusion_of :photo_uploader, in: PHOTO_UPLOADERS
  validates_presence_of :photo_uploader
  validates_presence_of :photo_uploader_image
  validates_presence_of :photo_uploader_version
end
