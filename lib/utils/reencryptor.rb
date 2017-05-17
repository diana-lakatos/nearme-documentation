# frozen_string_literal: true
# Reencrypt encrypted data in database with different SECRET_KEY
# Please refer to konowledgebase/REENCRYPTING_PROTECTED_ATTRIBS.md for more details

module Utils
  class Reencryptor
    MODELS = [
      BankAccount,
      BillingAuthorization,
      Instance,
      Charge,
      CreditCard,
      InstanceClient,
      Payout,
      Refund,
      Webhook,
      MerchantAccount,
      PaymentMethod,
      PaymentGateway,
      PaymentTransfer,
      PaypalAccount,
      Shippings::ShippingProvider
    ].freeze

    def initialize(old_key:, instance_id: nil)
      @old_key = old_key

      if instance_id.present?
        instance = Instance.find(instance_id)
        instance.set_context!
      end
    end

    def process_data!
      MODELS.each do |model|
        model.find_each do |model_object|
          p "Checking #{model.name} ##{model_object.id}"
          attrs = {}

          attrs = model.encrypted_attributes.inject({}) do |result, attribute|
            if attribute[1][:if]
              begin
                if value = model_object.send(attribute[1][:attribute])
                  result[attribute[1][:attribute]] = encrypt_data(model_object, attribute[0], value)
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
            p 'Sucessfully updated'
          elsif attrs && attrs.any?
            p 'FAILURE!!!'
            p model_object.errors
          else
            p 'Nothing to update'
          end
        end
      end
    end

    private

    def encrypt_data(object, attribute_name, value)
      object.class.encrypt(
        attribute_name,
        decrypt_data(object, attribute_name, value),
        key: DesksnearMe::Application.config.secret_token,
        marshal: false,
        encryptor: ::Encryptor
      )
    end

    def decrypt_data(object, attribute_name, value)
      object.class.decrypt(
        attribute_name,
        value,
        key: @old_key,
        marshal: false,
        encryptor: ::Encryptor
      )
    end
  end
end
