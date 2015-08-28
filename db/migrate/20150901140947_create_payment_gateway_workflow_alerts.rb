class CreatePaymentGatewayWorkflowAlerts < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      i.set_context!
      puts "Adding payment gateway workflow alerts to #{i.name}"
      Utils::DefaultAlertsCreator::PaymentGatewayCreator.new.create_all!
    end
  end

  def down
  end
end
