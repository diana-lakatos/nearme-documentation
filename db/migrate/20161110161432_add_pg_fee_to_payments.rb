# frozen_string_literal: true
class AddPgFeeToPayments < ActiveRecord::Migration
  def up
    add_column :payments, :payment_gateway_fee_cents, :integer, default: 0
    add_column :payment_transfers, :payment_gateway_fee_cents, :integer, default: 0

    instance = Instance.find_by(id: 195)
    return if instance.nil?
    PaymentTransfer.reset_column_information
    instance.set_context!
    Payment.update_all('payment_gateway_fee_cents = total_amount_cents * 0.029 + 30')
    PaymentTransfer.find_each do |pt|
      pt.payment_gateway_fee_cents = pt.payments.inject(0) { |sum, rc| sum += rc.payment_gateway_fee_cents }
      pt.amount_cents = pt.payments.all.inject(0) { |sum, rc| sum += rc.subtotal_amount_cents_after_refund } - pt.service_fee_amount_host_cents - pt.payment_gateway_fee_cents
      pt.save!
    end
  end

  def down
    remove_column :payments, :payment_gateway_fee_cents
    remove_column :payment_transfers, :payment_gateway_fee_cents
  end
end
