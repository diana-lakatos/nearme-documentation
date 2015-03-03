module Attachable
  class PaymentDocument < Attachment
    mount_uploader :file, PaymentDocumentUploader

    has_one :payment_document_info, class_name: 'Attachable::PaymentDocumentInfo', foreign_key: 'attachment_id', dependent: :destroy

    accepts_nested_attributes_for :payment_document_info

    validates_presence_of :file, if: :check_file_presence?

    self.per_page = 20

    private

    def check_file_presence?
      payment_document_info.document_requirement.item.upload_obligation.required?
    end
  end
end
