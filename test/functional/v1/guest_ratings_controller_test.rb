require 'test_helper'

class V1::GuestRatingsControllerTest < ActionController::TestCase

  setup do
    stub_mixpanel
    authenticate!
    @reservation = FactoryGirl.create(:reservation)
  end

  test "successfull add rating as host" do
    @reservation.listing.location.company.update_attribute(:creator_id, @user.id)
    @reservation.listing.location.company.add_creator_to_company_users
    @tracker.expects(:submitted_a_rating).with do |user, custom_options|
      user == @user && custom_options == {positive: true}
    end
    assert_difference('GuestRating.count') do
      post :create, {
        reservation_id: @reservation.id,
        guest_rating: {
          value: "1"
        },
        format: 'json'
      }    
    end
    assert :success
  end

  test "not creating guest rating as guest" do
    @reservation.update_attribute(:owner_id, @user.id)
    @tracker.expects(:submitted_a_rating).never
    assert_raise ActiveRecord::RecordNotFound do
      post :create, {
        reservation_id: @reservation.id,
        guest_rating: {
          value: "1"
        },
        format: 'json'
      }    
    end
    assert :success
  end

end
