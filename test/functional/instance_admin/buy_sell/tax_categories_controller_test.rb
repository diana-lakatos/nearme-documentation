require 'test_helper'

class InstanceAdmin::BuySell::TaxCategoriesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    FactoryGirl.create(:transactable_type_buy_sell)
    @tax_category = FactoryGirl.create(:tax_category)
  end

  context 'index' do
    should 'show a listing of tax categories' do
      get :index
      assert_select 'td', @tax_category.name
    end
  end

  context "create" do
    should 'allow create tax category' do
      assert_difference 'Spree::TaxCategory.count', 1 do
        post :create, tax_category: { name: 'new name', description: 'test' }
      end
      assert_redirected_to instance_admin_buy_sell_tax_categories_path
    end

    should 'have only one category as default' do
      @tax_category.update_column(:is_default, true)
      post :create, tax_category: { name: 'new name', description: 'test', is_default: '1' }
      @tax_category.reload
      assert_equal @tax_category.is_default?, false
    end
  end

  context "edit" do
    should 'allow show edit form for related tax category' do
      get :edit, id: @tax_category.id
      assert_response :success
    end
  end

  context 'destroy' do
    should 'destroy tax category' do
      assert_difference 'Spree::TaxCategory.count', -1 do
        delete :destroy, id: @tax_category.id
      end
      assert_redirected_to instance_admin_buy_sell_tax_categories_path
    end
  end

end
