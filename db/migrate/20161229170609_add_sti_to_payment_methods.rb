class AddStiToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_methods, :type, :string
    add_column :payment_methods, :encrypted_settings, :text

    PaymentMethod.reset_column_information

    PaymentMethod.all.each do |pm|
      pm.update_attribute(:type,  "PaymentMethod::#{pm.payment_method_type.classify}PaymentMethod")
    end
  end
end
