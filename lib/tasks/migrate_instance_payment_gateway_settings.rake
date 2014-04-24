namespace :migrate_instance_payment_gateway_settings do
  desc "Migrate Instance payment gateway related settings to InstancePaymentGateway"
  task :start => :environment do

    begin
      Instance.all.each do | instance |

        # transfer Stripe settings
        test_settings = { api_key: instance.test_stripe_api_key, public_key: instance.test_stripe_public_key, currency: instance.stripe_currency }
        live_settings = { api_key: instance.live_stripe_api_key, public_key: instance.live_stripe_public_key, currency: instance.stripe_currency }

        i = instance.instance_payment_gateways.create(payment_gateway_id: PaymentGateway.stripe.id, test_settings: test_settings, live_settings: live_settings)
        i.valid? ? puts("Migrated Stripe data for instance #{i.instance.id}") : puts("Stripe data migration failed for instance #{i.instance.id}")

        # transfer Balanced settings
        test_settings = { api_key: instance.test_balanced_api_key }
        live_settings = { api_key: instance.live_balanced_api_key }
        i = instance.instance_payment_gateways.create(payment_gateway_id: PaymentGateway.balanced.id, test_settings: test_settings, live_settings: live_settings)
        i.valid? ? puts("Migrated Balanced data for instance #{i.instance.id}") : puts("Balanced data migration failed for instance #{i.instance.id}")

        # transfer PayPal settings
        test_settings = { 
          email: instance.paypal_email, 
          username: instance.test_paypal_username, 
          password: instance.test_paypal_password, 
          signature: instance.test_paypal_signature,
          app_id: instance.test_paypal_app_id, 
          client_id: instance.test_paypal_client_id, 
          client_secret: instance.test_paypal_client_secret
        }
        live_settings = { 
          email: instance.paypal_email, 
          username: instance.live_paypal_username, 
          password: instance.live_paypal_password, 
          signature: instance.live_paypal_signature, 
          app_id: instance.live_paypal_app_id, 
          client_id: instance.live_paypal_client_id, 
          client_secret: instance.live_paypal_client_secret 
        }

        i = instance.instance_payment_gateways.create(payment_gateway_id: PaymentGateway.paypal.id, test_settings: test_settings, live_settings: live_settings)
        i.valid? ? puts("Migrated PayPal data for instance #{i.instance.id}") : puts("PayPal data migration failed for instance #{i.instance.id}")

        2.times { puts }
      end

      puts "Done."
    rescue => e
      puts 'Aborting migration:'
      puts e
    end
  end
end