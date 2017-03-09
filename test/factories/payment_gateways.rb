# frozen_string_literal: true
FactoryGirl.define do
  factory :payment_gateway do
    test_settings { { api_key: 'present' } }
    live_settings { { api_key: 'present' } }

    after :build do |payment_gateway, _payment_methods|
      payment_gateway.build_payment_methods(true)
    end

    before(:create) do |payment_gateway|
      payment_gateway.payment_countries << (Country.find_by(iso: 'US') || FactoryGirl.create(:country_us))
    end

    before(:create) do |payment_gateway|
      payment_gateway.payment_currencies << (Currency.find_by(iso_code: 'USD') || FactoryGirl.create(:currency_us))
    end

    after :create do |payment_gateway|
      payment_gateway.update_attributes(test_active: true, live_active: true)
    end

    factory :paypal_payment_gateway, class: PaymentGateway::PaypalPaymentGateway do
      before(:create) do |payment_gateway|
        payment_gateway.payment_currencies << (Currency.find_by(iso_code: 'JPY') || FactoryGirl.create(:currency_jpy))
      end

      test_settings do
        {
          email: 'sender_test@example.com',
          login: 'john_test',
          password: 'pass_test',
          signature: 'sig_test',
          app_id: 'app-123_test'
        }
      end
      live_settings do
        {
          email: 'sender_live@example.com',
          login: 'john_live',
          password: 'pass_live',
          signature: 'sig_live',
          app_id: 'app-123_live'
        }
      end
    end

    factory :paypal_adaptive_payment_gateway, class: PaymentGateway::PaypalAdaptivePaymentGateway do
      test_settings do
        {
          email: 'sender_test@example.com',
          login: 'john_test',
          password: 'pass_test',
          signature: 'sig_test',
          app_id: 'app-123_test'
        }
      end
      live_settings do
        {
          email: 'sender_live@example.com',
          login: 'john_live',
          password: 'pass_live',
          signature: 'sig_live',
          app_id: 'app-123_live'
        }
      end
    end

    factory :paypal_express_payment_gateway, class: PaymentGateway::PaypalExpressPaymentGateway do
      test_settings do
        {
          email: 'sender_test@example.com',
          login: 'john_test',
          password: 'pass_test',
          signature: 'sig_test',
          app_id: 'app-123_test',
          partner_id: '2EWXNHVCGY3JL'
        }
      end
      live_settings do
        {
          email: 'sender_live@example.com',
          login: 'john_live',
          password: 'pass_live',
          signature: 'sig_live',
          app_id: 'app-123_live',
          partner_id: '2EWXNHVCGY3JL'
        }
      end
    end

    factory :paypal_express_chain_payment_gateway, class: PaymentGateway::PaypalExpressChainPaymentGateway do
      test_settings do
        {
          email: 'sender_test@example.com',
          login: 'john_test',
          password: 'pass_test',
          signature: 'sig_test',
          app_id: 'app-123_test',
          partner_id: '2EWXNHVCGY3JL'
        }
      end
      live_settings do
        {
          email: 'sender_live@example.com',
          login: 'john_live',
          password: 'pass_live',
          signature: 'sig_live',
          app_id: 'app-123_live',
          partner_id: '2EWXNHVCGY3JL'
        }
      end
    end

    factory :stripe_payment_gateway, class: PaymentGateway::StripePaymentGateway do
      test_settings { { login: 'sk_test_DoIom7ZOL848ziY39cC75lI0' } }
      live_settings { { login: 'sk_test_DoIom7ZOL848ziY39cC75lI0' } }
    end

    factory :fetch_payment_gateway, class: PaymentGateway::FetchPaymentGateway do
      before(:create) do |payment_gateway|
        payment_gateway.payment_countries = [Country.find_by(iso: 'NZ') || FactoryGirl.create(:country_nz)]
      end

      before(:create) do |payment_gateway|
        payment_gateway.payment_currencies = [Currency.find_by(iso_code: 'NZD') || FactoryGirl.create(:currency_nzd)]
      end

      test_settings { { account_id: '123456789', secret_key: '987654321' } }
      live_settings { { account_id: '123456789', secret_key: '987654321' } }
    end

    factory :braintree_payment_gateway, class: PaymentGateway::BraintreePaymentGateway do
      test_settings { { merchant_id: '123456789', public_key: '987654321', private_key: '321543', supported_currency: 'USD' } }
      live_settings { { merchant_id: '123456789', public_key: '987654321', private_key: '321543', supported_currency: 'USD' } }
    end

    factory :braintree_marketplace_payment_gateway, class: PaymentGateway::BraintreeMarketplacePaymentGateway do
      test_settings { { merchant_id: '123456789', public_key: '987654321', private_key: '321543', supported_currency: 'USD', master_merchant_account_id: 'master_id' } }
      live_settings { { merchant_id: '123456789', public_key: '987654321', private_key: '321543', supported_currency: 'USD', master_merchant_account_id: 'master_id' } }
    end

    factory :stripe_connect_payment_gateway, class: PaymentGateway::StripeConnectPaymentGateway do
      test_settings { { login: 'sk_test_DoIom7ZOL848ziY39cC75lI0' } }
      live_settings { { login: '123456789' } }
    end

    factory :direct_stripe_sconnect_payment_gateway, class: PaymentGateway::StripeConnectPaymentGateway do
      test_settings { { login: 'sk_test_DoIom7ZOL848ziY39cC75lI0', publishable_key:  'pk_test_P54WUkDA1vryMRtw300Ajshi'} }
      live_settings { { login: 'sk_test_DoIom7ZOL848ziY39cC75lI0', publishable_key: 'pk_test_P54WUkDA1vryMRtw300Ajshi' } }
      config  { {'settings' => {"charge_type"=>"direct"}, "transfer_schedule"=>{"interval"=>"default"}} }
    end

    factory :manual_payment_gateway, class: PaymentGateway::ManualPaymentGateway do
    end
  end
end
