class Attachable::PaymentDocumentDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def document_info_label
    object.try(:payment_document_info).try(:document_requirement).try(:label).presence || object.file.file_name
  end

  def attachable_link
    h.link_to "#{t('dashboard.payment_documents.reservation')} #{ attachable.id }", attachable.transactable.decorate.show_path
  end

  def uploaded_file_link
    link_to "#{t('dashboard.user_reservations.uploaded_file')}: #{object.try(:payment_document_info).try(:document_requirement).try(:label).presence || object.file.file_name}", object.file.url, target: '_blank'
  end
end
