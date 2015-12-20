require 'test_helper'

class InstanceAdmin::BuySell::TaxRatesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    FactoryGirl.create(:transactable_type_buy_sell)
    @tax_rate = FactoryGirl.create(:tax_rate)
  end

  context 'index' do
    should 'show a listing of tax rates' do
      get :index
      assert_select 'td', @tax_rate.name
    end
  end

  context "create" do
    should 'allow create tax rate' do
      @tax_category = FactoryGirl.create(:tax_category)
      @zone         = FactoryGirl.create(:zone)

      assert_difference 'Spree::TaxRate.count', 1 do
        post :create, tax_rate: { "name" => "new name",
                                  "amount" => "10",
                                  "zone_id" => @zone.id,
                                  "tax_category_id" => @tax_category.id,
                                  "included_in_price" => "0"}
      end
      assert_redirected_to instance_admin_buy_sell_tax_rates_path
    end
  end

  context "edit" do
    should 'allow show edit form for related tax rate' do
      get :edit, id: @tax_rate.id
      assert_response :success
    end
  end

  context 'destroy' do
    should 'destroy tax rate' do
      assert_difference 'Spree::TaxRate.count', -1 do
        delete :destroy, id: @tax_rate.id
      end
      assert_redirected_to instance_admin_buy_sell_tax_rates_path
    end
  end

end
