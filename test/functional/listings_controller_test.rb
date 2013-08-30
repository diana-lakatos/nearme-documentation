require 'test_helper'

class ListingsControllerTest < ActionController::TestCase

  context '#index' do
    setup do
      FactoryGirl.create(:instance)
    end

    context '#params page' do
      should 'show listings if no page param is defined' do
        get :index
        assert :success
      end

      should 'redirect if page param is string' do
        get :index, :page => 'this is string'
        assert_redirected_to listings_path(:page => 1)
      end

      should 'redirect if page param is 0' do
        get :index, :page => 0
        assert_redirected_to listings_path(:page => 1)
      end

      should 'redirect if page param is mixed integer and string' do
        get :index, :page => '12this is string'
        assert_redirected_to listings_path(:page => 1)
      end
    end

  end

end

