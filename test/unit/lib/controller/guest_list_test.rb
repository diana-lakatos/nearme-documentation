require 'test_helper'

class GuestListTest < ActiveSupport::TestCase

  context '#filter' do
    setup do
      Timecop.travel(Time.local(2013, 10, 21, 12, 0, 0))
      @user = create(:user)
      @company = create(:company, creator: @user)
      @location = create(:location, company: @company)
      @listings = create(:listing, quantity: 10, location: @location)
      @unconfirmed_reservation =  create(:reservation, listing: @listings, state: :unconfirmed)
      @confirmed_reservation =  create(:reservation, listing: @listings, state: :confirmed)

      @archived_reservations = []
      Timecop.travel(7.days.ago) { @archived_reservations << create(:reservation, listing: @listings, state: :cancelled_by_guest) }
      Timecop.travel(8.days.ago) { @archived_reservations << create(:reservation, listing: @listings, state: :cancelled_by_host) }
      Timecop.travel(9.days.ago) { @archived_reservations << create(:reservation, listing: @listings, state: :rejected) }

      (10..12).each do |i|
        Timecop.travel(i.days.ago) { @archived_reservations << create(:reservation, listing: @listings, state: :confirmed) }
      end

      @guest_list = Controller::GuestList.new(@user)
    end

    teardown do
      Timecop.return
    end

    should 'filter unconfirmed reservation for user' do
      assert_equal [@unconfirmed_reservation], @guest_list.filter('unconfirmed').reservations
      assert_equal [@unconfirmed_reservation], @guest_list.filter('fake_state').reservations
    end

    should 'filter confirmed reservation for user' do
      assert_equal [@confirmed_reservation], @guest_list.filter('confirmed').reservations
    end

    should 'filter archived reservation for user' do
      assert_equal @archived_reservations.sort_by(&:date).reverse, @guest_list.filter('archived').reservations
    end
  end

end
