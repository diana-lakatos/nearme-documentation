# frozen_string_literal: true
class ActivityFeedImage < ActiveRecord::Base

  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :owner, polymorphic: true, touch: true
  belongs_to :uploader, class_name: 'User'
  belongs_to :instance

  validates :image, presence: true
  validates :owner_type, presence: true

  mount_uploader :image, ActivityFeedImageUploader

end
