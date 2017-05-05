# frozen_string_literal: true
require 'test_helper'

class MerchantAccountTest < ActiveSupport::TestCase
  context 'payment gateway with separate test/live merchant accounts' do
    setup do
      MerchantAccount::StripeConnectMerchantAccount.any_instance.stubs(:onboard!)
    end

    should 'have separate test account for test mode' do
      Instance.any_instance.stubs(test_mode?: true)
      merchant_account = create_merchant_account
      assert_equal merchant_account, merchant_account.merchantable.reload.merchant_accounts.mode_scope.first
      Instance.any_instance.stubs(test_mode?: false)
      assert_nil merchant_account.merchantable.reload.merchant_accounts.mode_scope.first
      Instance.any_instance.stubs(test_mode?: true)
      assert_equal merchant_account, merchant_account.merchantable.reload.merchant_accounts.mode_scope.first
    end

    should 'have separate account for live mode' do
      Instance.any_instance.stubs(test_mode?: false)
      merchant_account = create_merchant_account
      assert_equal merchant_account, merchant_account.merchantable.reload.merchant_accounts.mode_scope.first
      Instance.any_instance.stubs(test_mode?: true)
      assert_nil merchant_account.merchantable.reload.merchant_accounts.mode_scope.first
    end

    should 'proces accounts in various format including IBAN' do
      MerchantAccount::StripeConnectMerchantAccount.any_instance.stubs(:iso_country_code).returns('AU')
      MerchantAccount::StripeConnectMerchantAccount.any_instance.stubs(:get_currency).returns('AUD')
      {
        '000123456789' => '000123456789',
        '000123-456' => '000123-456',
        '000000001234567897' => '000000001234567897',
        'DE89370400440532013000' => 'DE89370400440532013000',
        'DE 8937 0400 4405 3201 3000' => 'DE89370400440532013000'
      }.each do |bank_account_key, bank_account_value|
        merchant_account = MerchantAccount::StripeConnectMerchantAccount.new
        merchant_account.bank_account_number = bank_account_key
        assert_equal bank_account_value, merchant_account.bank_account_hash[:bank_account][:account_number]
      end
    end

    should 'only require personal_id_numebr if validation set' do
      merchant_account = create_merchant_account
      merchant_account.owners.first.personal_id_number = nil
      assert merchant_account.valid?
      merchant_account.payment_gateway.config[:validate_merchant_account] = [:personal_id_number]
      refute merchant_account.valid?
    end
  end


  def create_merchant_account
    merchant_account = FactoryGirl.build(:stripe_connect_merchant_account)
    address = FactoryGirl.build(:full_address_in_sf)
    address.stubs('parse_address_components!').returns(true)
    address.stubs(:state_code).returns('CA')
    merchant_account.owners.first.current_address = address
    merchant_account.save
    merchant_account
  end
end
