class Attachable::PaymentDocumentDecorator < Draper::Decorator
  include Draper::LazyHelpers
  
  delegate_all

  def document_info_label
    object.try(:payment_document_info).try(:document_requirement).try(:label).presence || object.file.file_name 
  end

  def attachable_link
    if attachable.is_a?(Spree::Order)
      if attachable.user == current_user
        h.link_to "#{t('dashboard.payment_documents.order')} #{ attachable.number }", dashboard_order_path(attachable) 
      else
        h.link_to "#{t('dashboard.payment_documents.order')} #{ attachable.number }", dashboard_company_orders_received_path(attachable)
      end
    else
      h.link_to "#{t('dashboard.payment_documents.reservation')} #{ attachable.id }", listing_path(attachable.listing)
    end
  end
end