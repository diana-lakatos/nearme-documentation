require 'test_helper'

class InstanceAdmin::BuySell::ConfigurationControllerTest < ActionController::TestCase

  setup do
    PlatformContext.current = PlatformContext.new(FactoryGirl.create(:instance))
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    FactoryGirl.create(:transactable_type_buy_sell)
  end

  context 'show' do

    should 'show a listing of configurations associated with current instance' do
      get :show
      assert_select 'label', "Choose currency"
      assert_select 'h4', 'Currency symbol position'
      assert_select 'h4', 'Currency mark and separator'
      assert_select 'h4', 'Displaying modules options'
    end
  end

  context 'update' do
    should 'update Spree config' do
      update_hash = { "currency"=>"UYU",
                     "currency_symbol_position"=>"before",
                     "currency_decimal_mark"=>".",
                     "currency_thousands_separator"=>",",
                     "infinite_scroll"=>"false",
                     "random_products_for_cross_sell"=>"true" }
      put :update, update_hash
      update_hash.each_pair do |k, v|
        assert_equal Spree::Config[k].to_s, v
      end
    end
  end
end
