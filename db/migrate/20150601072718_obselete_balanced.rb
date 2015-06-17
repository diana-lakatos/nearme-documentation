class ObseleteBalanced < ActiveRecord::Migration
  class PaymentGateway < ActiveRecord::Base
  end

  def change
    PaymentGateway.where(type: 'PaymentGateway::BalancedPaymentGateway').delete_all
  end

end

