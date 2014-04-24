namespace :migrate_instance_payment_gateway_settings do
  desc "Migrate Instance payment gateway related settings to InstancePaymentGateway"
  task :start => :environment do

    begin
      2.times{puts}
      Instance.all.each do | instance |

        @stripe = PaymentGateway.where(method_name: "stripe").first
        @balanced = PaymentGateway.where(method_name: "balanced").first
        @paypal = PaymentGateway.where(method_name: "paypal").first


        # MIGRATE Stripe SETTINGS

        if instance.test_stripe_api_key.present? && instance.live_stripe_api_key.present?
          test_settings = { login: instance.test_stripe_api_key }
          live_settings = { login: instance.live_stripe_api_key }

          i = instance.instance_payment_gateways.create(payment_gateway_id: @stripe.id, test_settings: test_settings, live_settings: live_settings)
          if i.valid?
            puts("Creating country settings for Stripe for Instance ##{i.instance.id}")
            @stripe.supported_countries.each do | country_code |
              c = instance.country_instance_payment_gateways.where(country_alpha2_code: country_code).first_or_initialize
              c.instance_payment_gateway_id = i.id
              c.save
              c.valid? ? puts("#{country_code} settings created for Stripe for ##{i.instance.id}") : puts("#{country_code} settings failed for Stripe for ##{i.instance.id}")
            end
            2.times{puts}
          else
            puts("Stripe data migration failed for instance ##{i.instance.id}")
          end
        end

        # MIGRATE Balanced SETTINGS

        if instance.test_balanced_api_key.present? && instance.live_balanced_api_key.present?
          test_settings = { login: instance.test_balanced_api_key }
          live_settings = { login: instance.live_balanced_api_key }
          i = instance.instance_payment_gateways.create(payment_gateway_id: @balanced.id, test_settings: test_settings, live_settings: live_settings)
          if i.valid? && !instance.live_stripe_api_key.present?
            puts("Creating country settings for Balanced for Instance ##{i.instance.id}")
            @balanced.supported_countries.each do | country_code |
              c = instance.country_instance_payment_gateways.where(country_alpha2_code: country_code).first_or_initialize
              c.instance_payment_gateway_id = i.id
              c.save
              c.valid? ? puts("#{country_code} settings created for Balanced for ##{i.instance.id}") : puts("#{country_code} settings failed for Balanced for ##{i.instance.id}")
            end
            2.times{puts}
          else
            puts("Stripe data migration failed for instance ##{i.instance.id}")
          end
        end


        # MIGRATE Paypal SETTINGS

        if instance.paypal_email.present?

          test_settings = { 
            email: instance.paypal_email, 
            login: instance.test_paypal_username, 
            password: instance.test_paypal_password, 
            signature: instance.test_paypal_signature,
            app_id: instance.test_paypal_app_id
          }
          live_settings = { 
            email: instance.paypal_email, 
            login: instance.live_paypal_username, 
            password: instance.live_paypal_password, 
            signature: instance.live_paypal_signature, 
            app_id: instance.live_paypal_app_id
          }

          i = instance.instance_payment_gateways.create(payment_gateway_id: @paypal.id, test_settings: test_settings, live_settings: live_settings)
          if i.valid? && !instance.live_stripe_api_key.present?
            puts("Creating country settings for Paypal for Instance ##{i.instance.id}")
            @paypal.supported_countries.each do | country_code |
              c = instance.country_instance_payment_gateways.where(country_alpha2_code: country_code).first_or_initialize
              c.instance_payment_gateway_id = i.id
              c.save
              c.valid? ? puts("#{country_code} settings created for Paypal for ##{i.instance.id}") : puts("#{country_code} settings failed for Paypal for ##{i.instance.id}")
            end
            2.times{puts}
          else
            puts("Stripe data migration failed for instance ##{i.instance.id}")
          end
        end

        2.times{puts}
      end

      puts "Done."
    rescue => e
      puts 'Aborting migration:'
      puts e
    end
  end
end