module Attachable
  class PaymentDocumentInfo < ActiveRecord::Base
    has_paper_trail
    auto_set_platform_context
    scoped_to_platform_context
    acts_as_paranoid

    belongs_to :payment_document, class_name: 'Attachment', foreign_key: 'attachment_id'
    belongs_to :document_requirement
    belongs_to :instance
  end
end
