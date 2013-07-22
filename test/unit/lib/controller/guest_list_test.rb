require 'test_helper'

class GuestListTest < ActiveSupport::TestCase

  context '#filter' do
    setup do
      @user = create(:user)
      @company = create(:company, creator: @user)
      @location = create(:location, company: @company)
      @listings = create(:listing, quantity: 10, location: @location)
      @unconfirmed_reservation =  create(:reservation, listing: @listings, state: :unconfirmed)
      @confirmed_reservation =  create(:reservation, listing: @listings, state: :confirmed)

      @period = create(:reservation_period, date: (Time.zone.today - 1.day))
      @archived_reservations =  [create(:reservation, listing: @listings, state: :cancelled),
                                 create(:reservation, listing: @listings, state: :rejected),
                                 create(:reservation, state: :confirmed, listing: @listings, periods: [@period])]
      @guest_list = Controller::GuestList.new(@user)
    end

    should 'filter unconfirmed reservation for user' do
      assert_equal [@unconfirmed_reservation], @guest_list.filter('unconfirmed').reservations
      assert_equal [@unconfirmed_reservation], @guest_list.filter('fake_state').reservations
    end

    should 'filter confirmed reservation for user' do
      assert_equal [@confirmed_reservation], @guest_list.filter('confirmed').reservations
    end

    should 'filter archived reservation for user' do
      assert_equal @archived_reservations, @guest_list.filter('archived').reservations
    end
  end

end
