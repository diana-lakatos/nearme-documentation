require 'test_helper'

class Manage::ListingsControllerTest < ActionController::TestCase

include Devise::TestHelpers

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user   
    @listing = FactoryGirl.create(:listing)
    @listing.creator = @user
    @listing.save!
  end

  test "price with hyphen" do
    put :update, :id => @listing.id, :listing => { "daily_price"=>"50-100" }
    @listing.reload
    assert_equal 5000, @listing.price_cents
  end

  test "price with other strange characters" do
    put :update, :id => @listing.id, :listing => { "daily_price"=>"50.0-!@\#$%^&*()100" }
    @listing.reload
    assert_equal 5000, @listing.price_cents
  end

  test "negative price is 0" do
    put :update, :id => @listing.id, :listing => { "daily_price"=>"-100" }
    @listing.reload
    assert_equal 0, @listing.price_cents
  end

end
