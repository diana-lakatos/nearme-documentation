# frozen_string_literal: true
class PhotoUploadVersion < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  TRANSFORM_FUNCTIONS = %w(resize_to_fill resize_to_fit resize_and_pad resize_to_limit).freeze

  PHOTO_UPLOADERS = {
    'PhotoUploader' => PhotoUploader.dimensions,
    'AvatarUploader' => AvatarUploader.dimensions,
    'AuthorAvatarUploader' => AuthorAvatarUploader.dimensions,
    'CkeditorPictureUploader' => CkeditorPictureUploader.dimensions,
    'GroupCoverImageUploader' => GroupCoverImageUploader.dimensions,
    'HeroImageUploader' => HeroImageUploader.dimensions,
    'LinkImageUploader' => LinkImageUploader.dimensions,
    'SimpleAvatarUploader' => SimpleAvatarUploader.dimensions,
    'TopicCoverImageUploader' => TopicCoverImageUploader.dimensions,
    'TopicImageUploader' => TopicImageUploader.dimensions
  }.freeze

  belongs_to :theme, touch: true

  validates :version_name, uniqueness: { scope: [:theme_id, :photo_uploader] }
  validates :apply_transform, inclusion: { in: TRANSFORM_FUNCTIONS }
  validates :photo_uploader, inclusion: { in: PHOTO_UPLOADERS.keys }
  validates :width, numericality: { greater_than_or_equal_to: 0 }
  validates :height, numericality: { greater_than_or_equal_to: 0 }

  def self.can_regenerate_for_uploader?(uploader)
    !PlatformContext.current.instance.scheduled_uploaders_regenerations.where(photo_uploader: uploader).exists?
  end
end
