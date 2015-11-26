class ApprovalRequestAttachment < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :uploader, -> { with_deleted }, class_name: 'User'
  belongs_to :approval_request, -> { with_deleted }, inverse_of: :approval_request_attachments
  belongs_to :approval_request_attachment_template

  scope :for_attachment_template, -> (template_id) { where(approval_request_attachment_template_id: template_id) }
  scope :free,                    -> { where(approval_request_id: nil) }
  scope :for_request_or_free,     -> (request_id) { where(approval_request_id: [nil, request_id]) }

  mount_uploader :file, PrivateFileUploader
  validates_presence_of :file, unless: lambda { |ara| ara.file.present? || ara.file_cache.present? || !ara.required? }
  skip_callback :commit, :after, :remove_file!

end

