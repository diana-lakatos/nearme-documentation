# frozen_string_literal: true
require 'test_helper'
require 'helpers/gmaps_fake'

class StripeMerchantAccountBuilderTest < ActiveSupport::TestCase
  setup do
    GmapsFake.stub_requests
    stub_stripe
    @user = FactoryGirl.create(:user)
    @company = FactoryGirl.create(:company, creator: @user)
    @payment_gateway = FactoryGirl.create(:stripe_connect_payment_gateway)
    @merchant_account = MerchantAccount.new(merchantable: @company, type: @payment_gateway.merchant_account_type)
    @merchant_account.payment_gateway = @payment_gateway

    @merchant_account_builder = FormBuilder.new(base_form: StripeMerchantAccountForm,
                                                configuration: {},
                                                object: @merchant_account).build
  end

  should 'correctly validate empty params' do
    @merchant_account_builder.prepopulate!

    refute @merchant_account_builder.validate({})
    messages = [
      "Bank account number can't be blank",
      "Bank routing number can't be blank",
      'Account type is not included in the list',
      "Tos can't be blank",
      "Owners first name can't be blank",
      "Owners last name can't be blank",
      "Owners dob formated can't be blank",
      "Owners attachements file can't be blank"
    ]
    assert_equal messages, @merchant_account_builder.errors.full_messages
  end

  should 'correctly validate dob' do
    @merchant_account_builder.prepopulate!

    refute @merchant_account_builder.validate(owners: [{ dob_formated: '11111111' }])
    assert_includes @merchant_account_builder.errors.full_messages, 'Owners dob formated is invalid'
  end

  should 'save all parameters' do
    assert @merchant_account_builder.validate(parameters), @merchant_account_builder.errors.full_messages.join(', ')
    assert_difference 'MerchantAccount.count' do
      @merchant_account_builder.save
    end
    merchant_account = MerchantAccount.last
    assert_equal 'individual', merchant_account.account_type
    assert_equal '*2345', merchant_account.bank_account_number
    assert_equal 'Jane', merchant_account.owners.first.first_name
    assert_equal 'Frost St', merchant_account.owners.first.current_address.street
    assert_equal 'Canada', merchant_account.owners.first.current_address.country
  end

  should 'fail on saving company' do
    @merchant_account_builder.validate(invalid_company_parameters)
    @merchant_account_builder.save
    assert_equal({ business_tax_id: [["can't be blank"]] }, @merchant_account_builder.errors.messages)
  end

  should 'save all parameters for company' do
    @merchant_account_builder = FormBuilder.new(base_form: StripeMerchantAccountForm,
                                                configuration: { business_tax_id: {} },
                                                object: @merchant_account).build
    assert @merchant_account_builder.validate(company_parameters), @merchant_account_builder.errors.full_messages.join(', ')
    assert_difference 'MerchantAccount.count' do
      @merchant_account_builder.save
    end
    merchant_account = MerchantAccount.last
    assert_equal 'company', merchant_account.account_type
    assert_equal '*2345', merchant_account.bank_account_number
    assert_equal 'Jane', merchant_account.owners.first.first_name
    assert_equal 'Frost St', merchant_account.owners.first.current_address.street
  end

  protected

  def parameters
    {
      account_type: 'individual',
      currency: 'CAD',
      bank_account_number: '12345',
      bank_routing_number: '1234',
      tos: '1',
      owners: [
        {
          first_name: 'Jane', last_name: 'Doe', dob_formated: '01-01-1980',
          current_address: address_params,
          attachements: [
            { file: File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')) },
            { file: File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')) }
          ]
        }
      ]
    }
  end

  def invalid_company_parameters
    {
      account_type: 'company',
      bank_account_number: '12345',
      bank_routing_number: '1234',
      tos: '1',
      owners: [
        {
          first_name: 'Jane', last_name: 'Doe', dob_formated: '01-01-1980',
          current_address: address_params,
          attachements: [
            { file: File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')) },
            { file: File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')) }
          ]
        }
      ]
    }
  end

  def company_parameters
    {
      account_type: 'company',
      bank_account_number: '12345',
      bank_routing_number: '1234',
      business_tax_id: '1234',
      tos: '1',
      owners: [
        {
          first_name: 'Jane', last_name: 'Doe', dob_formated: '01-01-1980',
          current_address: address_params,
          attachements: [
            { file: File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')) },
            { file: File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')) }
          ]
        }
      ]
    }
  end

  def address_params
    {
      street: 'Frost St',
      city: 'Torronto',
      state: 'Quebec',
      country: 'Canada',
      postcode: '00001',
      iso_country_code: 'CA',
      raw_address: '1'
    }
  end

  def stub_stripe
    response = File.read(File.join(Rails.root, 'features', 'fixtures', 'stripe_responses', 'account_create.json'))
    stub_request(:post, /https:\/\/api.stripe.com\/v1\/accounts*/).to_return(status: 200, body: response)
    stub_request(:post, 'https://uploads.stripe.com/v1/files').to_return(status: 200, body: file_response_body)
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
