require 'test_helper'

class GuestListTest < ActiveSupport::TestCase
  context '#filter' do
    setup do
      stub_active_merchant_interaction
      @user = create(:user)
      @company = create(:company, creator: @user)
      @location = create(:location, company: @company)
      @transactables = create(:transactable, quantity: 10, location: @location)
      @unconfirmed_reservation =  create(:future_reservation, transactable: @transactables, state: :unconfirmed)
      @confirmed_reservation =  create(:future_reservation, transactable: @transactables, state: :confirmed)

      @archived_reservations = []
      travel_to(7.days.ago) { @archived_reservations << create(:reservation, transactable: @transactables, archived_at: Time.zone.now, state: :cancelled_by_guest) }
      travel_to(8.days.ago) { @archived_reservations << create(:reservation, transactable: @transactables, archived_at: Time.zone.now, state: :cancelled_by_host) }
      travel_to(9.days.ago) { @archived_reservations << create(:reservation, transactable: @transactables, archived_at: Time.zone.now, state: :rejected) }

      (10..12).each do |i|
        travel_to(i.days.ago) { @archived_reservations << create(:reservation, transactable: @transactables, archived_at: Time.zone.now, state: :confirmed) }
      end

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
      assert_equal @archived_reservations.sort_by(&:created_at).reverse, @guest_list.filter('archived').reservations
    end
  end
end
