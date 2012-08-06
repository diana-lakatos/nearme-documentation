require 'test_helper'

class V1::RatingsControllerTest < ActionController::TestCase

  setup do
    @user    = users(:one)
    @listing = listings(:one)
    @rating  = ratings(:one)
    @user.ensure_authentication_token!
    @request.env['Authorization'] = @user.authentication_token
  end

  test "should show rating for current user" do
    @rating.destroy
    assert_nil @listing.rating_for(@user)

    get :show, listing_id: @listing.id
    assert_response :success
    json = JSON.parse response.body
    assert_nil json["rating"]
  end

  test "should update rating for current user" do
    @listing.rate_for_user 5.0, @user
    assert_equal 5.0, @listing.rating_for(@user)

    raw_put :update, { listing_id: @listing.id }, '{ "rating": 3.5 }'
    assert_response :success
    json = JSON.parse response.body

    assert_equal 3.5, @listing.rating_for(@user)
    assert_equal 3.5, json["rating"]
  end

  test "should delete rating for current user" do
    @listing.rate_for_user 5.0, @user
    assert_equal 5.0, @listing.rating_for(@user)

    delete :destroy, listing_id: @listing.id
    assert_response :success
    json = JSON.parse response.body
    assert_nil json["rating"]
  end

  test "show should display a rating" do
    get :show, listing_id: @listing.id
    assert_response :success
  end

  test "update should create a rating for a listing" do
    raw_put :update, {listing_id: @listing.id}, rating_params.to_json
    assert_response :success
  end

  test "destroy should destroy a rating for a listing" do
    assert_difference('Rating.count', -1) do
      delete :destroy, listing_id: @listing.id
    end
    assert_response :success
  end

  def rating_params
    {
      "rating" => 5.0
    }
  end

end
