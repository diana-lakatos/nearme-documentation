class ChangePaymentGatewayClassToPaymentGatewayIdReference < ActiveRecord::Migration
  def up
    add_column :billing_authorizations, :payment_gateway_id, :integer, index: true
    add_column :credit_cards, :payment_gateway_id, :integer, index: true
    add_column :merchant_accounts, :payment_gateway_id, :integer, index: true
    add_column :instance_clients, :payment_gateway_id, :integer, index: true
    add_column :charges, :payment_gateway_id, :integer, index: true
    add_column :refunds, :payment_gateway_id, :integer, index: true

    Instance.find_each do |i|
      i.set_context!
      puts "updating data for #{i.name}"
      braintree_id = i.payment_gateways.where(type: 'PaymentGateway::BraintreePaymentGateway').first.try(:id)
      stripe_id = i.payment_gateways.where(type: 'PaymentGateway::StripePaymentGateway').first.try(:id)
      balanced_id = i.payment_gateways.where(type: 'PaymentGateway::BalancedPaymentGateway').first.try(:id)
      BillingAuthorization.find_each do |ba|
        id = begin
               case ba.payment_gateway_class
               when 'Billing::Gateway::Processor::Incoming::Braintree'
                 braintree_id
               when 'Billing::Gateway::Processor::Incoming::Stripe'
                 stripe_id
               when 'Billing::Gateway::Processor::Incoming::Balanced'
                 balanced_id
               end
             end
        ba.update_column(:payment_gateway_id, id) if id
      end

      if braintree_id
        CreditCard.where(gateway_class: 'Billing::Gateway::Processor::Incoming::Braintree').update_all(payment_gateway_id: braintree_id)
        InstanceClient.where(gateway_class: 'Billing::Gateway::Processor::Incoming::Braintree').update_all(payment_gateway_id: braintree_id)
      end

      if stripe_id
        CreditCard.where(gateway_class: 'Billing::Gateway::Processor::Incoming::Stripe').update_all(payment_gateway_id: stripe_id)
        InstanceClient.where(gateway_class: 'Billing::Gateway::Processor::Incoming::Stripe').update_all(payment_gateway_id: stripe_id)
      end

      if balanced_id
        CreditCard.where(gateway_class: 'Billing::Gateway::Processor::Incoming::Balanced').update_all(payment_gateway_id: balanced_id)
        InstanceClient.where(gateway_class: 'Billing::Gateway::Processor::Incoming::Balanced').update_all(payment_gateway_id: balanced_id)
      end

      [Refund, Charge].each do |object|
        object.find_each do |c|
          begin
            id = case c.response.params.keys.first
                 when "braintree_transaction"
                   braintree_id
                 when "id", "error"
                   stripe_id
                 when "debits", "status"
                   balanced_id
                 end
            c.update_column(:payment_gateway_id, id) if id

          rescue => e
            puts "Error while processing charge #{c.id}: #{e}, probably we can live with itw"
          end
        end
      end
    end
  end

  def down
    remove_column :billing_authorizations, :payment_gateway_id
    remove_column :instance_clients, :payment_gateway_id
    remove_column :merchant_accounts, :payment_gateway_id
    remove_column :credit_cards, :payment_gateway_id
  end

end
