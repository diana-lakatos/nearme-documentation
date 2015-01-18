class AddBraintreePaymentGateway < ActiveRecord::Migration
  class PaymentGateway < ActiveRecord::Base
    serialize :settings, Hash
  end

  def up
    PaymentGateway.create(
      name: "Braintree",
      method_name: 'braintree',
      settings: {
        merchant_id: "",
        public_key: "",
        private_key: "",
        supported_currency: ""},
      active_merchant_class: "ActiveMerchant::Billing::BraintreeBlueGateway"
    )
  end

  def down
    PaymentGateway.find_by_name("Braintree").try(:destroy)
  end
end
