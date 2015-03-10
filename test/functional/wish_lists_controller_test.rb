require 'test_helper'

class WishListControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @location = FactoryGirl.create(:location_in_auckland)
    @listing = FactoryGirl.create(:transactable, location: @location)
    @wish_list = FactoryGirl.create(:default_wish_list, user: @user)
    @product = FactoryGirl.create(:base_product)
    sign_in @user
  end

  context 'wish lists enabled' do
    setup do
      PlatformContext.current.instance.update_attribute :wish_lists_enabled, true
    end

    should 'add location' do
      get :add_item, object_id: @location.id, wishlistable_type: @location.class.name
      assert_response :redirect
      assert flash[:notice].include?('Item has been added to the list.')
    end

    should 'add product' do
      get :add_item, object_id: @product.id, wishlistable_type: @product.class.name
      assert_response :redirect
      assert flash[:notice].include?('Item has been added to the list.')
    end

    should 'add different items' do
      assert_difference 'WishListItem.count' do
        get :add_item, object_id: @product.id, wishlistable_type: @product.class.name
      end
      assert_response :redirect

      assert_difference 'WishListItem.count' do
        get :add_item, object_id: @location.id, wishlistable_type: @location.class.name
      end
      assert_response :redirect
    end

    should 'not add same item twice' do
      FactoryGirl.create(:wish_list_item, wish_list: @wish_list, wishlistable: @location)
      get :add_item, object_id: @location.id, wishlistable_type: @location.class.name
      assert_response :redirect
      assert flash[:notice].include?('This item is already in the list.')
    end

    should 'remove item' do
      FactoryGirl.create(:wish_list_item, wish_list: @wish_list, wishlistable: @location)
      get :remove_item, object_id: @location.id, wishlistable_type: @location.class.name
      assert_response :redirect
      assert flash[:notice].include?('Item has been removed from the list.')
    end

    should 'allow only permitted classes' do
      assert_raise WishListItem::NotPermitted do
        get :add_item, object_id: @location.id, wishlistable_type: 'User'
      end
    end
  end

  context 'wish lists disabled' do
    setup do
      PlatformContext.current.instance.update_attribute :wish_lists_enabled, false
    end

    should 'not add item' do
      get :add_item, object_id: @location.id, wishlistable_type: @location.class.name
      assert_response :redirect
      assert flash[:notice].include?('Wish lists are disabled for this marketplace.')
    end
  end
end
