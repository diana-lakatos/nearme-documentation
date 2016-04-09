class PopuatePayerId < ActiveRecord::Migration
  def up
    puts "Populating payment's and payment subscription's payer_id"
    Payment.find_each do |p|
      begin
        p.update_column(:payer_id, p.payable.owner.id)
      rescue
        puts "\tFailed to update for: Payment #{p.id}"
      end
    end

    PaymentSubscription.find_each do |p|
      begin
        p.update_column(:payer_id, p.subscriber.owner.id)
      rescue
        puts "\tFailed to update for: PaymentSubscription #{p.id}"
      end
    end

  end

  def down
  end
end
