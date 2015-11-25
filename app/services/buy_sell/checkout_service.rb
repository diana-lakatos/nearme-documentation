class BuySell::CheckoutService
  def initialize(user, order, params = {})
    @order = order
    @params = params.permit(SecuredParams.new.spree_order)
    @user = user
  end

  def build_payment_documents
    requirement_ids = @order.payment_documents.map do |pd|
      pd.payment_document_info.document_requirement.id
    end

    @order.line_items.each do |item|
      if item.product.document_requirements.blank? &&
        PlatformContext.current.instance.documents_upload_enabled?
        item.product.document_requirements.create({
          label: I18n.t("upload_documents.file.default.label"),
          description: I18n.t("upload_documents.file.default.description")
        })
      end

      if item.product.upload_obligation.blank? &&
        PlatformContext.current.instance.documents_upload_enabled?
        item.product.create_upload_obligation(level: UploadObligation.default_level)
      end

      item.product.document_requirements.each do |req|
        if !req.item.upload_obligation.not_required? && !requirement_ids.include?(req.id)
          document = @order.payment_documents.build(
            attachable: @order,
            user: @user
          )
          document.build_payment_document_info(document_requirement: req)
        end
      end
    end
  end

  def update_payment_documents
    if @params[:payment_documents_attributes].present?
      @params[:payment_documents_attributes].each do |document|
        document_requirement_id = document.last.try(:fetch, 'payment_document_info_attributes').try(:fetch, 'document_requirement_id')
        if document.last['file'].present? ||
          DocumentRequirement.find_by(id: document_requirement_id).try(:item).try(:upload_obligation).required?

          if document.last['id'].present?
            Attachable::PaymentDocument.find_by(id: document.last['id']).update_attributes(document.last)
          else
            @order.payment_documents.create(document.last.to_hash)
          end
        end
      end
    end
    build_payment_documents if PlatformContext.current.instance.documents_upload_enabled?
  end
end
