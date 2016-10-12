class Listings::ReservationsService
  def initialize(user, reservation_request, params = {})
    @user = user
    @reservation_request = reservation_request
    @params = params
  end

  def build_documents
    requirement_ids = @reservation_request.reservation.payment_documents.map do |pd|
      pd.payment_document_info.document_requirement.id
    end

    @reservation_request.listing.document_requirements.each do |req|
      if !req.item.upload_obligation.not_required? && !requirement_ids.include?(req.id) && PlatformContext.current.instance.documents_upload_enabled?
        document = @reservation_request.reservation.payment_documents.build(user: @user)
        document.payment_document_info = Attachable::PaymentDocumentInfo.new(
          document_requirement: req,
          payment_document: document
        )
      end
    end

    if @reservation_request.listing.upload_obligation.blank? &&
       @reservation_request.listing.document_requirements.blank? &&
       PlatformContext.current.instance.documents_upload_enabled? &&
       (PlatformContext.current.instance.documents_upload.is_mandatory? ||
       PlatformContext.current.instance.documents_upload.is_optional?)

      build_default_document_requirement
    end
  end

  def build_default_document_requirement
    document = @reservation_request.reservation.payment_documents.build
    document_requirement = @reservation_request.reservation.transactable.document_requirements.build(label: I18n.t('upload_documents.file.default.label'),
                                                                                                     description: I18n.t('upload_documents.file.default.description'))

    document.payment_document_info = Attachable::PaymentDocumentInfo.new(
      document_requirement: document_requirement,
      payment_document: document
    )
  end
end
