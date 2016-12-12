# frozen_string_literal: true
require 'test_helper'

class MerchantAccount::StripeConnectMerchantAccountTest < ActiveSupport::TestCase
  setup do
    User.any_instance.stubs(current_sign_in_ip: '192.168.1.1')

    @instance = current_instance
    @company = create(:company)
    @payment_gateway = FactoryGirl.create :stripe_connect_payment_gateway
    @merchant = MerchantAccount::StripeConnectMerchantAccount.new(merchantable: @company, payment_gateway: @payment_gateway)
  end

  should 'validate merchant account' do
    refute @merchant.save
    assert @merchant.errors.full_messages.include? "Bank Routing Number can't be blank"
    assert @merchant.errors.full_messages.include? "Social Security Number can't be blank"
  end

  should 'onboard valid merchant' do
    @merchant = FactoryGirl.build(:stripe_connect_merchant_account, payment_gateway: @payment_gateway, state: 'pending')
    @merchant.save

    response = File.read(File.join(Rails.root, 'features', 'fixtures', 'stripe_responses', 'account_create.json'))
    stub_request(:post, /https:\/\/api.stripe.com\/v1\/accounts*/).to_return(status: 200, body: response)
    stub_request(:post, 'https://uploads.stripe.com/v1/files').to_return(status: 200, body: file_response_body)

    refute @merchant.verified?

    address = FactoryGirl.build(:full_address_in_sf)
    address.stubs('parse_address_components!').returns(true)
    address.stubs(:state_code).returns('CA')
    @merchant.current_address = address

    @merchant.save
    assert @merchant.fields_needed.present?
    refute @merchant.verified?
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
end
