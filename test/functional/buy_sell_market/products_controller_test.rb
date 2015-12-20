require 'test_helper'

class BuySellMarket::ProductsControllerTest < ActionController::TestCase

  setup do
    @product = FactoryGirl.create(:product)
  end

  context 'show' do

    should 'render show action' do
      get :show, id: @product
      assert_select 'h1', @product.name
      assert_response :success
    end

    should 'track impression' do
      assert_difference 'Impression.count' do
        get :show, id: @product
      end
    end

    context 'no user' do
      should 'render user info even if deleted' do
        @user = @product.administrator
        @user.destroy
        get :show, id: @product
        assert_select 'h1', @product.name
        assert_select '.vendor-info h2', @user.name
        assert_response :success
      end
      should 'render show even if user is hard-deleted' do
        @product.administrator.delete
        get :show, id: @product
        assert_select 'h1', @product.name
        assert_response :success
      end
    end
  end

end
