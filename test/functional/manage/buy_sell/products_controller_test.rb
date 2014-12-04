require 'test_helper'

class Manage::BuySell::ProductsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @company = FactoryGirl.create(:company, creator: @user)
    @product = FactoryGirl.create(:product)
    @product.company = @company
    @product.save

    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  should 'create new product' do
    assert_difference 'Spree::Product.count' do
      post :create, product: {name: "Test product", price: '10', shipping_category_id: FactoryGirl.create(:shipping_category).id}
    end
  end

  should 'edit product name' do
    put :update, product: {name: 'Changed name'}, id: @product.slug
    assert assigns(:product).name, @product.reload.name
  end
end
