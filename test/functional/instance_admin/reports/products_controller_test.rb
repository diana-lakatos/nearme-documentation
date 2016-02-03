require 'test_helper'

class InstanceAdmin::Reports::ProductsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  should 'delete product from reports' do
    product = FactoryGirl.create(:product)

    assert_equal true, Spree::Product.exists?(product)

    delete :destroy, { id: product.id }

    assert_equal false, Spree::Product.exists?(product)
  end

  should 'see product information' do
    product = FactoryGirl.create(:product)

    get :show, { id: product.id }

    assert_select 'th', 'Attribute'
    assert_select 'th', 'Value'
  end

end

