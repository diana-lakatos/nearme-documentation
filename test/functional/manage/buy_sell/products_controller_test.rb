require 'test_helper'

class Manage::BuySell::ProductsControllerTest < ActionController::TestCase

  setup do
    @company = FactoryGirl.create(:company)
    @product = FactoryGirl.create(:product)
    @product.company = @company
    @product.save
    @user = @company.creator
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  should 'create new product' do
    assert_difference 'Spree::Product.count' do
      post :create, product: FactoryGirl.attributes_for(:product)
    end
  end

  should 'edit product name' do
    put :update, product: {name: 'Changed name'}, id: @product.slug
    assert assigns(:product).name, @product.reload.name
  end
end
