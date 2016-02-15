class AssociatePaymentsWithPaymentMethods < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      i.set_context!
      puts "Processing payments for #{i.name}"
      Payment.find_each do |p|
        begin
          if p.payable.try(:payment_method_id)
            puts "#{p.id} associating payment_method_id to the same that was used for payable"
            p.update_attribute(:payment_method_id, p.payable.try(:payment_method_id))
          else
            if p.payment_gateway.nil?
              puts "\t#{p.id} belongs to nil payment gateway"
            elsif p.payment_gateway.payment_methods.count == 1
              puts "\tOne choice, associating #{p.id} with payment method"
              p.payment_method = p.payment_gateway.payment_methods.first
              p.save!
            else
              manual = p.payment_gateway.payment_methods.find_by(payment_method_type: 'manual')
              free = p.payment_gateway.payment_methods.find_by(payment_method_type: 'free')
              credit_card = p.payment_gateway.payment_methods.find_by(payment_method_type: 'credit_card')
              paypal = p.payment_gateway.payment_methods.find_by(payment_method_type: 'express_checkout')
              nonce = p.payment_gateway.payment_methods.find_by(payment_method_type: 'nonce')
              if p.offline
                if manual
                  puts "\t#{p.id} associated with manual payment method"
                  p.payment_method = manual
                  p.save!
                else
                  puts "\tWARNING: #{p.id} no manual payment method"
                end
              elsif p.is_free?
                if free
                  puts "\t#{p.id} associated with free payment method"
                  p.payment_method = free
                  p.save!
                else
                  puts "\tWARNING: #{p.id} no free payment method"
                end
              elsif credit_card
                puts "\t#{p.id} associated with credit_card"
                p.payment_method = credit_card
                p.save!
              elsif paypal
                puts "\t#{p.id} associated with paypal"
                p.payment_method = paypal
                p.save!
              elsif nonce
                puts "\t#{p.id} associated with nonce"
                p.payment_method = nonce
                p.save!
              else
                puts "\tERROR: Not associated #{p.id}"
              end
            end
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
