class BuySell::CheckoutService
  def initialize(user, order, params = {})
    @order = order
    @params = params
    @user = user
  end

  def build_payment_documents
    requirement_ids = @order.payment_documents.map do |pd|
      pd.payment_document_info.document_requirement.id
    end

    @order.line_items.each do |item|
      item.product.document_requirements.each do |req|
        if !req.item.upload_obligation.not_required? && !requirement_ids.include?(req.id)
          document = @order.payment_documents.build( 
            attachable: @order, 
            user: @user
          )
          document.payment_document_info = Attachable::PaymentDocumentInfo.new(document_requirement: req, payment_document: document)
        end
      end
    end
  end

  def update_payment_documents
    if @params[:order][:payment_documents_attributes]
      @params[:order][:payment_documents_attributes].each do |doc|
        if doc.last['file'].present? || 
          DocumentRequirement.find(doc.last['payment_document_info_attributes']['document_requirement_id']).item.upload_obligation.required?
          if doc.last['id'].present?
            Attachable::PaymentDocument.find(doc.last['id']).update_attributes(doc.last)
          else
            @order.payment_documents.create(doc.last)
          end
        end
      end
    end
  end
end