require 'test_helper'

class InstanceAdmin::BuySell::ProductTypes::CategoriesControllerTest < ActionController::TestCase

  setup do
    stub_mixpanel
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    FactoryGirl.create(:transactable_type_buy_sell)
    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category, categorable: @product_type)
  end

  context 'index' do
    should 'show a listing of categories groups' do
      get :index , product_type_id: @product_type.id
      assert_select 'span.category-name', @category.name
    end
  end

  context "create" do
    should 'allow create category' do
      assert_difference 'Category.count', 1 do
        post :create, product_type_id: @product_type.id, category: { name: 'new name category'}
      end
      assert_redirected_to edit_instance_admin_buy_sell_product_type_category_path(@product_type, Category.where(name: 'new name category').last)
    end
  end

  context "edit" do
    should 'allow show edit form for related category' do
      get :edit, product_type_id: @product_type.id, id: @category.id
      assert_response :success
    end
  end

  context 'destroy' do
    should 'destroy category' do
      assert_difference 'Category.count', -1 do
        delete :destroy, product_type_id: @product_type.id, id: @category.id
      end
      assert_redirected_to instance_admin_buy_sell_product_type_categories_path(@product_type)
    end
  end

end
