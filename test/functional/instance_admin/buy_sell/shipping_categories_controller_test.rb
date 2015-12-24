require 'test_helper'

class InstanceAdmin::BuySell::ShippingCategoriesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    FactoryGirl.create(:transactable_type_buy_sell)
    @shipping_category = FactoryGirl.create(:shipping_category)
  end

  context 'index' do
    should 'show a listing of shipping categories' do
      get :index
      assert_select 'td', @shipping_category.name
    end
  end

  context "create" do
    should 'allow create shipping category' do
      assert_difference 'Spree::ShippingCategory.count', 1 do
        post :create, shipping_category: { name: 'new name'}
      end
      assert_redirected_to instance_admin_buy_sell_shipping_categories_path
    end
  end

  context "edit" do
    should 'allow show edit form for related shipping category' do
      get :edit, id: @shipping_category.id
      assert_response :success
    end
  end

  context 'destroy' do
    should 'destroy shipping category' do
      assert_difference 'Spree::ShippingCategory.count', -1 do
        delete :destroy, id: @shipping_category.id
      end
      assert_redirected_to instance_admin_buy_sell_shipping_categories_path
    end
  end

end
