class ScheduledUploadersRegeneration < ActiveRecord::Base

  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance

  validates_uniqueness_of :photo_uploader, scope: :instance_id

end
