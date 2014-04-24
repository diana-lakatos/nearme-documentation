class CreatePaymentGateways < ActiveRecord::Migration
  class PaymentGateway < ActiveRecord::Base
    attr_accessible :name, :method_name, :settings
    serialize :settings, ActiveRecord::Coders::Hstore

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
    stripe_settings = { api_key: "", public_key: "", currency: "USD" }
    balanced_settings = { api_key: "" }
    paypal_settings = { email: "", username: "", password: "", signature: "", app_id: "", client_id: "", client_secret: "" }

    payment_gateways = [
      { 
        name: "Stripe",
        settings: stripe_settings
      },
      {
        name: "Balanced",
        settings: balanced_settings
      },
      {
        name: "PayPal",
        settings: paypal_settings
      }
    ]

    PaymentGateway.create(payment_gateways)
  end

  def down
    drop_table :instance_payment_gateways
    drop_table :payment_gateways
  end  
end
