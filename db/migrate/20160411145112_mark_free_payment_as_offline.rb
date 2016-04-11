class MarkFreePaymentAsOffline < ActiveRecord::Migration
  def up
    opm_ids =  PaymentMethod.with_deleted.where(payment_method_type: ['free', 'manual']).map(&:id)
    Payment.where(payment_method_id: opm_ids, offline: false).each do |payment|
      payment.send(:set_offline)
      payment.save(validate: false)
    end
  end

  def down
  end
end
