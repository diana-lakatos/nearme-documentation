namespace :reencrypt do

  desc "Decrypt and encrypt again data with new secret_token. Provide OLD_KEY"
  task :all_data, [:old_key] => :environment do |t, args|
    old_key = ENV['OLD_KEY'].presence || args[:old_key]
    return p 'Variable OLD_KEY not provided.' if old_key.blank?

    models = [
      BillingAuthorization,
      Instance,
      Charge,
      CreditCard,
      InstanceClient,
      Payout,
      RecurringBooking,
      Refund,
      Webhook,
      MerchantAccount,
      PaymentGateway
    ]

    models.each do |model|
      model.find_each do |model_object|
        p "Checking #{model.name} ##{model_object.id}"
        attrs = {}

        attrs = model.encrypted_attributes.inject({}) do |result, attribute|
          if attribute[1][:if]
            begin
              if model_object.send(attribute[1][:attribute])
                old_value_decrypted = model.decrypt(attribute[0], model_object.send(attribute[1][:attribute]), key: old_key, marshal: false, encryptor: Encryptor)
                new_value = model.encrypt(attribute[0], old_value_decrypted, key: DesksnearMe::Application.config.secret_token, marshal: false, encryptor: Encryptor)
                result[attribute[1][:attribute]] =  new_value
              end
              result
            rescue OpenSSL::Cipher::CipherError => e
              p "Attribute already migrated #{e.message}"
              result
            rescue ArgumentError => e
              p "Attribute already migrated #{e.message}"
              result
            end
          else
            result
          end
        end

        if attrs && attrs.any? && model_object.update_columns(attrs)
           p "Sucessfully updated"
        elsif attrs && attrs.any?
          p "FAILURE!!!"
          p model_object.errors
        else
          p "Nothing to update"
        end
      end
    end
  end

end
