class PaymentDocumentSerializer < ApplicationSerializer
  attributes :id, :label, :file

  def label
    object.payment_document_info.document_requirement.label
  end
end
