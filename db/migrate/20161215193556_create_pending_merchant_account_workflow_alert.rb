class CreatePendingMerchantAccountWorkflowAlert < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      i.set_context!
      puts "Adding pending merchant account workflow alerts to #{i.name}"
      Utils::DefaultAlertsCreator::PaymentGatewayCreator.new.create_notify_host_about_merchant_account_requirements_email!
    end
  end

  def down
  end
end

