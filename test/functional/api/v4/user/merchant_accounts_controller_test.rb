# frozen_string_literal: true
require 'test_helper'

module Api
  module V4
    module User
      class MerchantAccountsControllerTest < ActionController::TestCase
        setup do
          stub_stripe
          @user = FactoryGirl.create(:user)
          @company = FactoryGirl.create(:company, creator: @user)
          sign_in @user
        end

        should 'raise error that payment gateway is not configured' do
          assert_raise PaymentGateway::NoPaymentGatewayForCredirCards do
            post :create, form_configuration_id: form_configuration.id, merchant_account: {}
          end
        end

        context 'with payment gateway' do
          setup do
            payment_gateway = FactoryGirl.create(:stripe_connect_payment_gateway)
            FactoryGirl.create(:credit_card_payment_method, payment_gateway: payment_gateway)
          end

          should 'create merchant account' do
            assert_difference 'MerchantAccount.count' do
              post :create, form_configuration_id: form_configuration.id, merchant_account: merchant_account_params
            end

            assert_redirected_to root_path
            merchant_account = MerchantAccount.last
            assert_equal 'individual', merchant_account.account_type
            assert_equal '*2345', merchant_account.bank_account_number
            assert_equal 'Jane', merchant_account.owners.first.first_name
            assert_equal 'Green', merchant_account.owners.first.current_address.street
          end

          should 'update merchant account' do
            post :create, form_configuration_id: form_configuration.id, merchant_account: merchant_account_params
            merchant_account = MerchantAccount.last

            put :update,
                form_configuration_id: form_configuration.id,
                id: merchant_account.id,
                merchant_account: {
                  bank_routing_number: '9999',
                  tos: '1'
                }

            assert_redirected_to root_path
            assert_equal '9999', MerchantAccount.last.bank_routing_number
          end
        end

        protected

        def form_configuration
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'merchant_account_form',
            base_form: 'StripeMerchantAccountForm',
            configuration: {}
          )
        end

        def stub_stripe
          response = File.read(File.join(Rails.root, 'features', 'fixtures', 'stripe_responses', 'account_create.json'))
          stub_request(:post, /https:\/\/api.stripe.com\/v1\/accounts*/).to_return(status: 200, body: response)
          stub_request(:post, 'https://uploads.stripe.com/v1/files').to_return(status: 200, body: file_response_body)
          stub_request(:get, /https:\/\/api.stripe.com\/v1\/accounts*/).to_return(status: 200, body: response)
        end

        def file_response_body
          {
            "id": 'file_19OUWJK2MWM5GsIT08B2h36X',
            "object": 'file_upload',
            "created": 1_481_213_599,
            "purpose": 'dispute_evidence',
            "size": 9863,
            "type": 'png'
          }.to_json
        end

        def merchant_account_params
          {
            account_type: 'individual',
            currency: 'USD',
            bank_account_number: '12345',
            bank_routing_number: '1234',
            tos: '1',
            owners: [
              {
                first_name: 'Jane', last_name: 'Doe', dob_formated: '01-01-1980', current_address: {
                  street: 'Green',
                  city: 'New York',
                  postcode: '00001',
                  state: 'New York',
                  country: 'United States',
                  iso_country_code: 'US',
                  raw_address: '1'
                },
                attachements_attributes: {
                  '0' => { file:  fixture_file_upload('avatar.jpg', 'image/jpg') },
                  '1' => { file:  fixture_file_upload('avatar.jpg', 'image/jpg') }
                }
              }
            ]
          }
        end
      end
    end
  end
end
