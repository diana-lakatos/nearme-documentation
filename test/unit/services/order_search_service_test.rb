require 'test_helper'

class OrderSearchServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @unconfirmed_reservation = FactoryGirl.create(:future_unconfirmed_reservation, user: @user)
    @reservation = FactoryGirl.create_list(:confirmed_reservation, 2, user: @user)
    @archived_reservation = FactoryGirl.create(:confirmed_reservation, user: @user, archived_at: Time.now.yesterday)
    @order_scope  = @user.orders.active
  end

  should 'find archived orders' do
    assert_equal 1, OrderSearchService.new(@order_scope, query: nil, state: 'archived',
                                                         type: ['Reservation']).orders.count
    assert_equal 2, OrderSearchService.new(@order_scope, state: 'confirmed').orders.count
    assert_equal 1, OrderSearchService.new(@order_scope, {}).orders.count
  end

  should 'assign correct counters' do
    assert_equal 1, OrderSearchService.new(@order_scope, {}).upcoming_count
    assert_equal 2, OrderSearchService.new(@order_scope, {}).confirmed_count
    assert_equal 1, OrderSearchService.new(@order_scope, {}).archived_count
  end
end
