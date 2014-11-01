require 'test_helper'

class BuySellMarket::ProductsControllerTest < ActionController::TestCase

  setup do
    @product = FactoryGirl.create(:product)
    stub_mixpanel
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
  end

end
