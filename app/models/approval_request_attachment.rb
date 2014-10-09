class ApprovalRequestAttachment < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :uploader, class_name: 'User'
  belongs_to :approval_request, inverse_of: :approval_request_attachments

  mount_uploader :file, PrivateFileUploader
  validates_presence_of :file, unless: lambda { |ara| ara.file.present? || ara.file_cache.present? || !ara.required? }
  skip_callback :commit, :after, :remove_file!

end

