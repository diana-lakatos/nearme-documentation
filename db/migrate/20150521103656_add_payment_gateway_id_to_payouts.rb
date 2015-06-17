class AddPaymentGatewayIdToPayouts < ActiveRecord::Migration
  def up
    add_column :payouts, :instance_id, :integer
    add_column :payouts, :payment_gateway_id, :integer
    add_index :payouts, [:instance_id, :payment_gateway_id]
    Payout.find_each do |payout|
      payout.update_column(:instance_id, payout.reference.instance_id) if payout.reference.present?
    end
  end

  def down
    remove_column :payouts, :instance_id, :integer
    remove_column :payouts, :payment_gateway_id, :integer
    remove_index :payouts, [:instance_id, :payment_gateway_id]
  end
end

