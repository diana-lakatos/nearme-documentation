require 'test_helper'

class WishListItemTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @wish_list = FactoryGirl.create(:default_wish_list, user: @user)
    @location = FactoryGirl.create(:location)
  end

  should 'increase or decrease counters on wishlistable' do
    assert_difference '@location.reload.wish_list_items_count' do
      @wish_list.items.create! wishlistable: @location
    end

    assert_difference '@location.reload.wish_list_items_count', -1 do
      @wish_list.items.find_by(wishlistable: @location).destroy
    end
  end
end
