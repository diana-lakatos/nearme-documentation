class ApprovalRequestAttachmentTemplate < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :approval_request_template, -> { with_deleted }, inverse_of: :approval_request_attachment_templates
  belongs_to :instance

  has_many :approval_request_attachments, inverse_of: :approval_request_attachment_template
end
