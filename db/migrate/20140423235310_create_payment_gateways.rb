class CreatePaymentGateways < ActiveRecord::Migration
  class PaymentGateway < ActiveRecord::Base
    attr_accessor :name, :method_name, :settings, :active_merchant_class
    serialize :settings, Hash

    before_save :set_method_name

    def set_method_name
      self.method_name = name.downcase.gsub(" ", "_")
    end
  end

  def up
    # create payment_gateways
    create_table :payment_gateways do |t|
      t.string :name
      t.string :method_name
      t.text :settings
      t.string :active_merchant_class

      t.timestamps
    end

    # create instance_payment_gateways
    create_table :instance_payment_gateways do |t|
      t.integer :instance_id
      t.integer :payment_gateway_id
      t.text :encrypted_live_settings
      t.text :encrypted_test_settings

      t.timestamps
    end

    # create default payment_gateways
    stripe_settings = { login: "" }
    balanced_settings = { login: "" }
    paypal_settings = { email: "", login: "", password: "", signature: "", app_id: "" }
    swipe_settings = { login: "", api_key: "" }
    sagepay_settings = { login: "", password: "" }
    worldpay_settings = { login: "" }
    paystation_settings = { paystation_id: "", gateway_id: "" }
    authorize_net_settings = { login: "", password: "" }
    ogone_settings = { login: "", user: "", password: "" }
    spreedly_settings = { login: "", password: "", gateway_token: "" }

    payment_gateways = [
      { 
        name: "Stripe",
        settings: stripe_settings,
        active_merchant_class: "ActiveMerchant::Billing::StripeGateway"
      },
      {
        name: "Balanced",
        settings: balanced_settings,
        active_merchant_class: "ActiveMerchant::Billing::BalancedGateway"
      },
      {
        name: "PayPal",
        settings: paypal_settings,
        active_merchant_class: "ActiveMerchant::Billing::PaypalGateway"
      },
      {
        name: "SagePay",
        settings: sagepay_settings,
        active_merchant_class: "ActiveMerchant::Billing::SagePayGateway"
      },
      {
        name: "Worldpay",
        settings: worldpay_settings,
        active_merchant_class: "ActiveMerchant::Billing::WorldpayGateway"
      },
      {
        name: "Paystation",
        settings: paystation_settings,
        active_merchant_class: "ActiveMerchant::Billing::PaystationGateway"
      },
      {
        name: "AuthorizeNet",
        settings: authorize_net_settings,
        active_merchant_class: "ActiveMerchant::Billing::AuthorizeNetGateway"
      },
      {
        name: "Ogone",
        settings: ogone_settings,
        active_merchant_class: "ActiveMerchant::Billing::OgoneGateway"
      },
      {
        name: "Spreedly",
        settings: spreedly_settings,
        active_merchant_class: "ActiveMerchant::Billing::SpreedlyCoreGateway"
      },
    ]

    PaymentGateway.create(payment_gateways)
  end

  def down
    drop_table :instance_payment_gateways
    drop_table :payment_gateways
  end  
end
