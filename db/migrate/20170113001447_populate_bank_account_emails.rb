class PopulateBankAccountEmails < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      puts "Creating bank account emails for #{i.name}"
      i.set_context!
      begin
        creator = Utils::DefaultAlertsCreator::PaymentGatewayCreator.new
        creator.create_notify_enquirer_of_bank_account_creation!
        creator.create_notify_enquirer_of_bank_account_verification!
      rescue
        puts "Was not able to generate alerts for: #{i.name}"
      end
    end
  end

  def down
  end
end

