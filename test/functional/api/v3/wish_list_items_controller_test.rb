# frozen_string_literal: true
require 'test_helper'

class Api::V3::WishListItemsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @location = FactoryGirl.create(:location_in_auckland)
    @transactable = FactoryGirl.create(:transactable, location: @location)
    @wish_list = FactoryGirl.create(:default_wish_list, user: @user)
    sign_in @user
  end

  context 'wish lists enabled' do
    setup do
      PlatformContext.current.instance.update_attribute :wish_lists_enabled, true
    end

    should 'return list of all wishlist items' do
      item1 = FactoryGirl.create(:wish_list_item, wish_list: @wish_list, wishlistable_id: @transactable.id)

      transactable2 = FactoryGirl.create(:transactable, location: @location)
      item2 = FactoryGirl.create(:wish_list_item, wish_list: @wish_list, wishlistable_id: transactable2.id)

      get :index, format: :json
      assert_equal 2, JSON.parse(response.body)['wish_list_items'].length
    end

    should 'add transactable to list' do
      post :create, id: @transactable.id, wishlistable_type: @transactable.class.name, format: :json
      assert_response :success
    end

    should 'add different items' do
      assert_difference 'WishListItem.count' do
        post :create, id: @transactable.id, wishlistable_type: @transactable.class.name, format: :json
      end
      assert_response :success
    end

    should 'not add same item twice' do
      FactoryGirl.create(:wish_list_item, wish_list: @wish_list, wishlistable: @transactable)
      post :create, id: @transactable.id, wishlistable_type: @transactable.class.name, format: :json
      assert_equal '{"errors":{"already_listed":"This item is already listed."}}', response.body
    end

    should 'remove item' do
      FactoryGirl.create(:wish_list_item, wish_list: @wish_list, wishlistable: @transactable)
      delete :destroy, id: @transactable.id, wishlistable_type: @transactable.class.name, format: :json
      assert_response :success
    end

    should 'allow only permitted classes' do
      assert_raise WishListItem::NotPermitted do
        post :create, id: @transactable.id, wishlistable_type: 'Company', format: :json
      end
    end
  end

  context 'wish lists disabled' do
    setup do
      PlatformContext.current.instance.update_attribute :wish_lists_enabled, false
    end

    should 'not add item' do
      assert_raise WishListItem::Disabled do
        post :create, id: @transactable.id, wishlistable_type: @transactable.class.name, format: :json
      end
    end
  end
end
