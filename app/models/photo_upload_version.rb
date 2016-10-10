class PhotoUploadVersion < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  TRANSFORM_FUNCTIONS = %w(resize_to_fill resize_to_fit resize_and_pad resize_to_limit)

  PHOTO_UPLOADERS = {
    'PhotoUploader' => PhotoUploader.dimensions,
    'AvatarUploader' => AvatarUploader.dimensions,
    'AuthorAvatarUploader' => AuthorAvatarUploader.dimensions,
    'CkeditorPictureUploader' => CkeditorPictureUploader.dimensions,
    'GroupCoverImageUploader' => GroupCoverImageUploader.dimensions,
    'LinkImageUploader' => LinkImageUploader.dimensions,
    'SimpleAvatarUploader' => SimpleAvatarUploader.dimensions,
    'TopicCoverImageUploader' => TopicCoverImageUploader.dimensions,
    'TopicImageUploader' => TopicImageUploader.dimensions
  }

  belongs_to :theme

  validates_uniqueness_of :version_name, scope: [:theme_id, :photo_uploader]
  validates_inclusion_of :apply_transform, in: TRANSFORM_FUNCTIONS
  validates_inclusion_of :photo_uploader, in: PHOTO_UPLOADERS.keys
  validates_numericality_of :width, greater_than_or_equal_to: 0
  validates_numericality_of :height, greater_than_or_equal_to: 0

  def self.can_regenerate_for_uploader?(uploader)
    !PlatformContext.current.instance.scheduled_uploaders_regenerations.where(photo_uploader: uploader).exists?
  end
end
