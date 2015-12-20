require 'test_helper'

class InstanceAdmin::BuySell::ShippingMethodsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    FactoryGirl.create(:transactable_type_buy_sell)
    @shipping_method = FactoryGirl.create(:shipping_method)
  end

  context 'index' do
    should 'show a listing of shipping methods' do
      get :index
      assert_select 'td', @shipping_method.name
    end
  end

  context "create" do
    should 'allow create shipping method' do
      @tax_category      = FactoryGirl.create(:tax_category)
      @shipping_category = FactoryGirl.create(:shipping_category)
      @zone              = FactoryGirl.create(:zone)

      assert_difference 'Spree::ShippingMethod.count', 1 do
        post :create, {
          shipping_method: {
                        name: 'new name',
                        price: '100',
                        tax_category_id: @tax_category.id,
                        shipping_category_ids: [@shipping_category.id],
                        zones_id: [@zone.id]
          },
          calculator_shipping_flat_rate: { preferred_amount: 100 }
        }
      end
      assert_redirected_to instance_admin_buy_sell_shipping_methods_path
    end
  end

  context "edit" do
    should 'allow show edit form for related shipping method' do
      get :edit, id: @shipping_method.id
      assert_response :success
    end
  end

  context 'destroy' do
    should 'destroy shipping method' do
      assert_difference 'Spree::ShippingMethod.count', -1 do
        delete :destroy, id: @shipping_method.id
      end
      assert_redirected_to instance_admin_buy_sell_shipping_methods_path
    end
  end

end
