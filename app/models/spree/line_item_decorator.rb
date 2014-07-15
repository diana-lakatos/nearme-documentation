Spree::LineItem.class_eval do
  include Spree::Scoper
  inherits_columns_from_association([:company_id], :order) if ActiveRecord::Base.connection.table_exists?(self.table_name)

  scope :needs_payment_transfer, -> {
    where(payment_transfer_id: nil).joins(:order).merge(Spree::Order.completed).readonly(false)
  }

  monetize :service_fee_amount_guest_cents
  monetize :service_fee_amount_host_cents

end
