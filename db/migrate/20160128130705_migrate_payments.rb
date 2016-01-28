class Reservation < ActiveRecord::Base
  belongs_to :payment_method
end

Spree::Order.class_eval do
  belongs_to :payment_method
end

class MigratePayments < ActiveRecord::Migration

  def up
    Instance.all.each do |instance|
      instance.set_context!

      Reservation.where("id NOT IN (SELECT payable_id FROM payments WHERE payable_type='Reservation')").each do |reservation|
        if (billing_authorization = reservation.billing_authorization).present? && reservation.payment_method.present? && reservation.payment_method.payment_gateway.present?
          state = billing_authorization.success? ? (billing_authorization.void_at.present? ? "voided" : "authorized") : "pending"
          payment = reservation.build_payment(
            payment_method_id: reservation.payment_method_id,
            state: state,
          )
          payment.payment_gateway_mode = billing_authorization.payment_gateway_mode
          payment.save!
          billing_authorization.update_attribute(:payment_id, payment)
        elsif reservation.payment_method.present? && reservation.payment_method.payment_gateway
          state = reservation.payment_status == 'unknown' ? 'pending' : reservation.payment_status
          payment = reservation.build_payment(
            payment_method: reservation.payment_method,
            state: state,
          )
          payment.currency ||= 'USD'
          payment.save!
        elsif reservation.old_payment_method == 'manual' && PaymentGateway::ManualPaymentGateway.any? && PaymentGateway::ManualPaymentGateway.first.payment_methods.manual.first
          payment = reservation.build_payment(
            payment_method: PaymentGateway::ManualPaymentGateway.first.payment_methods.manual.first,
            state: 'pending',
          )
          payment.save!
        elsif reservation.old_payment_method == 'remote' && PaymentGateway::FetchPaymentGateway.any? && PaymentGateway::FetchPaymentGateway.first.payment_methods.first
          payment = reservation.build_payment(
            payment_method: PaymentGateway::FetchPaymentGateway.first.payment_methods.first,
            state: 'pending',
          )
          payment.save!
        else
          payment = reservation.build_payment(state: 'pending')
          payment.currency ||= 'USD'
          payment.save(validate: false)
          payment.update_column(:payment_method_id, reservation.payment_method_id) if reservation.payment_method_id
        end
      end

      Spree::Order.where("id NOT IN (SELECT payable_id FROM payments WHERE payable_type='Spree::Order')").each do |order|
        if (billing_authorization = order.billing_authorization).present? && order.payment_method.present?
          state = billing_authorization.success? ? (billing_authorization.void_at.present? ? "voided" : "authorized") : "pending"
          payment = order.build_payment(
            payment_method_id: order.payment_method_id,
            state: state,
          )
          payment.payment_gateway_mode = billing_authorization.payment_gateway_mode
          payment.save!
          billing_authorization.update_attribute(:payment_id, payment)
        elsif order.payment_method.present?
          payment = order.build_payment(
            payment_method: order.payment_method,
            state: 'pending',
          )
          payment.save!
        elsif order.old_payment_method == 'manual' && PaymentMethod.manual.any?
          payment = order.build_payment(
            payment_method: PaymentMethod.manual.first,
            state: 'pending',
          )
          payment.save!
        else
          payment = order.build_payment(state: 'pending')
          payment.currency ||= 'USD'
          payment.save(validate: false)
          payment.update_column(:payment_method_id, order.payment_method_id) if order.payment_method_id
        end
      end

      # Update all missing payment states
      Payment.where(paid_at: nil, state: nil).
        joins("
          INNER JOIN reservations ON reservations.id = payments.payable_id
          AND payments.payable_type= 'Reservation'
          AND reservations.payment_status = 'authorized'
        ").update_all("state = 'authorized'")
      Payment.where.not(paid_at: nil).where(refunded_at: nil, state: nil).update_all("state = 'paid'")
      Payment.where.not(refunded_at: nil).where(state: nil).update_all("state ='refunded'")

      unless (count = Payment.where(state: nil).count).zero?
        puts "Looks like there are still #{count} payments to check for instance: #{instance.id}: #{instance.name}"
      end
    end
  end

  def down
  end
end
