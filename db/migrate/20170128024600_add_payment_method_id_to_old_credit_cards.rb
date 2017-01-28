class AddPaymentMethodIdToOldCreditCards < ActiveRecord::Migration
  def up
    CreditCard.find_each do |cc|
      if cc.payment_method_id.blank?
        pg = PaymentGateway.find_by_id(cc.payment_gateway_id)
        pm = pg.payment_methods.credit_card.first if pg
        cc.update_column :payment_method_id, pm.id if pm
      end
    end
  end

  def down
  end
end
