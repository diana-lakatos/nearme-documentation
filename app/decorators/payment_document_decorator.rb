class Attachable::PaymentDocumentDecorator < Draper::Decorator
  include Draper::LazyHelpers
  
  delegate_all

  def attachable_link
    if attachable.is_a?(Spree::Order)
      if attachable.user == current_user
        h.link_to "#{t('dashboard.payment_documents.order')} #{ attachable.number }", dashboard_order_path(attachable) 
      else
        h.link_to "#{t('dashboard.payment_documents.order')} #{ attachable.number }", dashboard_orders_received_path(attachable)
      end
    else
      h.link_to "#{t('dashboard.payment_documents.reservation')} #{ attachable.id }", listing_path(attachable.listing)
    end
  end
end