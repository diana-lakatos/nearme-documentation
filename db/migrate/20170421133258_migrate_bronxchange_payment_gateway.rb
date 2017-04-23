class MigrateBronxchangePaymentGateway < ActiveRecord::Migration
  def up
    puts "Adding require validations"
    Instance.all.each do |instance|
      puts "#{instance.id} - #{instance.name}"
      instance.set_context!
      PaymentGateway::StripeConnectPaymentGateway.all.each do |pg|
        pg.config = pg.config.merge({
          validate_merchant_account: [:attachements, :personal_id_number]
        })
        pg.save
      end

      MerchantAccountOwner::StripeConnectMerchantAccountOwner.all.each do |ma|
        ma.data['personal_id_number'] = nil
        ma.save(validate: false)
      end
    end
  end

  def down
  end
end
