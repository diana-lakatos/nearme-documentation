class AddFetchPaymentGateway < ActiveRecord::Migration
  class PaymentGateway < ActiveRecord::Base
    serialize :settings, Hash
  end

  def up
    PaymentGateway.create(
      name: "Fetch",
      method_name: 'fetch',
      settings: { account_id: "", secret_key: ""},
      active_merchant_class: "Billing::Gateway::Processor::Incoming::Fetch"
    )
  end

  def down
  end
end
