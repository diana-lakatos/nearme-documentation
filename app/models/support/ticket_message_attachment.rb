class Support::TicketMessageAttachment < ActiveRecord::Base
  self.table_name = 'support_ticket_message_attachments'
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :ticket_message, class_name: 'Support::TicketMessage'
  belongs_to :ticket, class_name: 'Support::Ticket'
  belongs_to :uploader, -> { with_deleted }, class_name: 'User'

  mount_uploader :file, PrivateFileUploader

  TAGS = ['Informational', 'Purchase Order']
  validates_presence_of :file
  validates_inclusion_of :tag, in: TAGS
end
