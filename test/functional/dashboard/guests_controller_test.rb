require 'test_helper'

class Dashboard::GuestsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @related_company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id)
    @related_location = FactoryGirl.create(:location_in_auckland, company: @related_company)
    @related_listing = FactoryGirl.create(:transactable, location: @related_location)
    @unrelated_listing = FactoryGirl.create(:transactable)
    @unrelated_listing.update_attribute(:instance_id, FactoryGirl.create(:instance).id)
  end

  should 'show related guests' do
    FactoryGirl.create(:reservation, owner: @user, listing: @related_listing)
    get :index
    assert_response :success
    assert_select ".order", 1
  end

  should 'show related locations when no related guests' do
    @reservation = FactoryGirl.create(:reservation, owner: @user, listing: @unrelated_listing)
    @reservation.update_attribute(:instance_id, @unrelated_listing.instance_id)
    get :index
    assert_response :success
    assert_select ".order", 0
    assert_select "h2", @related_location.name
  end

  should 'not show unrelated guests' do
    @reservation = FactoryGirl.create(:reservation, owner: @user, listing: @unrelated_listing)
    @reservation.update_attribute(:instance_id, @unrelated_listing.instance_id)
    get :index
    assert_response :success
    assert_select ".order", 0
  end

  should 'show tweet links if no reservation' do
    get :index
    assert_response :success
    assert_select ".sharelocation", 1
    assert_select ".sharelocation > span", 4
  end

  should 'not show tweet links if there is reservation' do
    FactoryGirl.create(:reservation, owner: @user, listing: @related_listing)
    get :index
    assert_response :success
    assert_select ".sharelocation", 0
  end

end
