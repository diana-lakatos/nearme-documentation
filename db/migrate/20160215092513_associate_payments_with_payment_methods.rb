class AssociatePaymentsWithPaymentMethods < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      i.set_context!
      puts "Processing payments for #{i.name}"
      Payment.where(payment_method_id: nil).each do |p|
        begin
        if p.payment_gateway.nil?
          puts "\t#{p.id} belongs to nil payment gateway"
        elsif p.payment_gateway.payment_methods.count == 1
          puts "\tOne choice, associating #{p.id} with payment method"
          p.payment_method = p.payment_gateway.payment_methods.first
          p.save!
        else
          puts "\tPayment #{p} needs to be associated with payment method (#{p.payment_gateway.payment_methods.count} choices)"
        end
        rescue => e
          puts "\tERROR!!! #{e}"
        end
      end
    end
  end

  def down
  end
end
