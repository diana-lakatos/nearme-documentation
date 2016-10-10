require 'test_helper'

class AvailabilitySearchTest < ActionDispatch::IntegrationTest
  setup do
    enable_elasticsearch!
    @date_start = Time.zone.now.next_week.to_date + 7.days
  end

  teardown do
    disable_elasticsearch!
  end

  context 'availability rules' do
    setup do
      @transactable_in_location_opened_from_mon_to_friday = FactoryGirl.create(:transactable)
      @transactable_opened_whole_week = FactoryGirl.create(:always_open_listing)
      @transactable_with_own_availability_rules_for_tuesday = FactoryGirl.create(:transactable)
      @transactable_with_own_availability_rules_for_tuesday.availability_template.availability_rules.destroy_all
      @transactable_with_own_availability_rules_for_tuesday.availability_template.availability_rules.create!(days: [2], open_hour: 9, close_hour: 18)
      @transactable_with_own_availability_rules_for_tuesday.save!
    end

    context 'strict mode' do
      setup do
        TransactableType.first.update_attribute(:date_pickers_mode, 'strict')
      end

      should 'get only listings that are booked for each day if search above week' do
        @date_end = @date_start + 14.days
        @params = { availability: { dates: { start: @date_start.to_s, end: @date_end.to_s } } }
        @searcher = InstanceType::Searcher::GeolocationSearcher::Listing.new(TransactableType.first, @params)
        @searcher.invoke
        assert_equal([@transactable_opened_whole_week].map(&:id).sort, @searcher.results.map(&:id).sort)
      end

      should 'get listings that are opened on all days' do
        @date_start += 3.day
        @date_end = @date_start + 5.days
        @params = { availability: { dates: { start: @date_start.to_s, end: @date_end.to_s } } }
        @searcher = InstanceType::Searcher::GeolocationSearcher::Listing.new(TransactableType.first, @params)
        @searcher.invoke
        assert_equal([@transactable_opened_whole_week].map(&:id).sort, @searcher.results.map(&:id).sort)
      end

      should 'include both listings with own and location rules' do
        @date_start += 1.day
        @params = { availability: { dates: { start: @date_start.to_s, end: @date_start.to_s } } }
        @searcher = InstanceType::Searcher::GeolocationSearcher::Listing.new(TransactableType.first, @params)
        @searcher.invoke
        assert_equal([
          @transactable_in_location_opened_from_mon_to_friday,
          @transactable_opened_whole_week,
          @transactable_with_own_availability_rules_for_tuesday
        ].map(&:id).sort, @searcher.results.map(&:id).sort)
      end
    end

    context 'relative modexxx' do
      setup do
        TransactableType.first.update_attribute(:date_pickers_mode, 'relative')
        Transactable.__elasticsearch__.refresh_index!
      end

      should 'get all listings if search for more than week' do
        @date_end = @date_start + 14.days
        @params = { availability: { dates: { start: @date_start.to_s, end: @date_end.to_s } } }
        @searcher = InstanceType::Searcher::Elastic::GeolocationSearcher::Listing.new(TransactableType.first, @params)
        @searcher.invoke
        assert_equal([
          @transactable_in_location_opened_from_mon_to_friday,
          @transactable_opened_whole_week,
          @transactable_with_own_availability_rules_for_tuesday].map(&:id).sort, @searcher.results.map(&:id).sort)
      end

      should 'get listings that are opened during at least one day' do
        @date_start += 4.days
        @date_end = @date_start + 1.days
        @params = { availability: { dates: { start: @date_start.to_s, end: @date_end.to_s } } }
        @searcher = InstanceType::Searcher::Elastic::GeolocationSearcher::Listing.new(TransactableType.first, @params)
        @searcher.invoke
        assert_equal([
          @transactable_opened_whole_week,
          @transactable_in_location_opened_from_mon_to_friday,
          @transactable_with_own_availability_rules_for_tuesday].map(&:id).sort, @searcher.results.map(&:id).sort)
      end
    end
  end

  context 'not booked scope' do
    setup do
      @date_end = @date_start + 2.days

      create_transactable_with_all_days_booked_for_three_days!
      create_transactable_with_some_days_fully_booked_via_one_reservation!
      create_transactable_with_some_days_fully_booked_via_multiple_reservations!

      create_transactable_with_some_days_fully_booked_on_other_days!
      create_transactable_without_reservations!
      create_disabled_transactable_without_reservations!
      create_transactable_with_all_days_booked_via_cancelled_rejected_expired_reservation!

      @params = { availability: { dates: { start: @date_start.to_s, end: @date_end.to_s } } }
    end

    context 'listings' do
      should 'return correct transactables' do
        TransactableType.first.update_attribute(:date_pickers_mode, 'relative')
        @params = { availability: { dates: { start: @date_start.to_s, end: @date_start.to_s } } }
        @searcher = InstanceType::Searcher::GeolocationSearcher::Listing.new(TransactableType.first, @params)
        @searcher.invoke
        assert_equal([
          @transactable_with_some_days_fully_booked_via_multiple_reservations,
          @transactable_with_some_days_fully_booked_on_other_days,
          @transactable_without_reservations,
          @transactable_with_all_days_booked_via_cancelled_rejected_expired_reservation
        ].map(&:id).sort, @searcher.results.map(&:id).sort)

        # return correct transactables for searching for 1 day difference
        @params = { availability: { dates: { start: @date_start.to_s, end: (@date_start + 1.day).to_s } } }
        @searcher = InstanceType::Searcher::GeolocationSearcher::Listing.new(TransactableType.first, @params)
        @searcher.invoke
        assert_equal([
          @transactable_with_some_days_fully_booked_via_one_reservation,
          @transactable_with_some_days_fully_booked_via_multiple_reservations,
          @transactable_with_some_days_fully_booked_on_other_days,
          @transactable_without_reservations,
          @transactable_with_all_days_booked_via_cancelled_rejected_expired_reservation
        ].map(&:id).sort, @searcher.results.map(&:id).sort)

        # return correct transactables for relative mode
        @params = { availability: { dates: { start: @date_start.to_s, end: @date_end.to_s } } }
        @searcher = InstanceType::Searcher::GeolocationSearcher::Listing.new(TransactableType.first, @params)
        @searcher.invoke
        assert_equal([
          @transactable_with_some_days_fully_booked_via_one_reservation,
          @transactable_with_some_days_fully_booked_via_multiple_reservations,
          @transactable_with_some_days_fully_booked_on_other_days,
          @transactable_without_reservations,
          @transactable_with_all_days_booked_via_cancelled_rejected_expired_reservation
        ].map(&:id).sort, @searcher.results.map(&:id).sort)

        # return correct transactables for strict mode
        TransactableType.first.update_attribute(:date_pickers_mode, 'strict')
        @params = { availability: { dates: { start: @date_start.to_s, end: @date_end.to_s } } }
        @searcher = InstanceType::Searcher::GeolocationSearcher::Listing.new(TransactableType.first, @params)
        @searcher.invoke
        assert_equal([
          @transactable_with_some_days_fully_booked_on_other_days,
          @transactable_without_reservations,
          @transactable_with_all_days_booked_via_cancelled_rejected_expired_reservation
        ].map(&:id).sort, @searcher.results.map(&:id).sort)

        # 'locations' should 'return correct transactables for relative mode'
        @params = { availability: { dates: { start: @date_start.to_s, end: @date_end.to_s } } }
        TransactableType.first.update_attribute(:date_pickers_mode, 'relative')
        @searcher = InstanceType::Searcher::GeolocationSearcher::Location.new(TransactableType.first, @params)
        assert_equal([
          @transactable_with_some_days_fully_booked_via_one_reservation,
          @transactable_with_some_days_fully_booked_via_multiple_reservations,
          @transactable_with_some_days_fully_booked_on_other_days,
          @transactable_without_reservations,
          @transactable_with_all_days_booked_via_cancelled_rejected_expired_reservation
        ].map(&:location_id).sort, @searcher.results.map(&:id).sort)

        # 'locations' should return correct transactables for strict mode
        TransactableType.first.update_attribute(:date_pickers_mode, 'strict')
        @searcher = InstanceType::Searcher::GeolocationSearcher::Location.new(TransactableType.first, @params)
        assert_equal([
          @transactable_with_some_days_fully_booked_on_other_days,
          @transactable_without_reservations,
          @transactable_with_all_days_booked_via_cancelled_rejected_expired_reservation
        ].map(&:location_id).sort, @searcher.results.map(&:id).sort)
      end
    end
  end

  protected

  def create_transactable_with_all_days_booked_for_three_days!
    @transactable_with_all_days_booked = FactoryGirl.create(:transactable, quantity: 2)
    2.times do
      reservation = FactoryGirl.build(:future_reservation, transactable: @transactable_with_all_days_booked)
      reservation.payment = FactoryGirl.build(:authorized_payment, payable: reservation)
      reservation.periods = []
      reservation.add_period(@date_start)
      reservation.add_period(@date_start + 1.days)
      reservation.add_period(@date_start + 2.days)
      reservation.save!
    end
  end

  def create_transactable_with_some_days_fully_booked_via_one_reservation!
    @transactable_with_some_days_fully_booked_via_one_reservation = FactoryGirl.create(:transactable, quantity: 5)
    reservation = FactoryGirl.build(:future_reservation, transactable: @transactable_with_some_days_fully_booked_via_one_reservation, quantity: 5)
    reservation.payment = FactoryGirl.build(:authorized_payment, payable: reservation)
    reservation.periods = []
    reservation.add_period(@date_start)
    reservation.save!
  end

  def create_transactable_with_some_days_fully_booked_via_multiple_reservations!
    @transactable_with_some_days_fully_booked_via_multiple_reservations = FactoryGirl.create(:transactable, quantity: 5)
    reservation = FactoryGirl.build(:future_reservation, transactable: @transactable_with_some_days_fully_booked_via_multiple_reservations, quantity: 3)
    reservation.payment = FactoryGirl.build(:authorized_payment, payable: reservation)
    reservation.periods = []
    reservation.add_period(@date_start)
    reservation.add_period(@date_start + 2.days)
    reservation.save!
    reservation = FactoryGirl.build(:future_reservation, transactable: @transactable_with_some_days_fully_booked_via_multiple_reservations, quantity: 2)
    reservation.payment = FactoryGirl.build(:authorized_payment, payable: reservation)
    reservation.periods = []
    reservation.add_period(@date_start + 2.days)
    reservation.add_period(@date_start + 1.days)
    reservation.save!
  end

  def create_transactable_with_some_days_fully_booked_on_other_days!
    @transactable_with_some_days_fully_booked_on_other_days = FactoryGirl.create(:transactable, quantity: 5)
    reservation = FactoryGirl.build(:future_reservation, transactable: @transactable_with_some_days_fully_booked_on_other_days, quantity: 5)
    reservation.payment = FactoryGirl.build(:authorized_payment, payable: reservation)
    reservation.periods = []
    reservation.add_period(@date_start - 1.day)
    reservation.add_period(@date_end + 1.day)
    reservation.save!
    reservation = FactoryGirl.build(:future_reservation, transactable: @transactable_with_some_days_fully_booked_on_other_days, quantity: 2)
    reservation.payment = FactoryGirl.build(:authorized_payment, payable: reservation)
    reservation.periods = []
    reservation.add_period(@date_start + 1.day)
    reservation.save!
  end

  def create_transactable_without_reservations!
    @transactable_without_reservations = FactoryGirl.create(:transactable, quantity: 1)
  end

  def create_disabled_transactable_without_reservations!
    @disabled_transactable_without_reservations = FactoryGirl.create(:transactable, quantity: 1, enabled: false)
  end

  def create_transactable_with_all_days_booked_via_cancelled_rejected_expired_reservation!
    Reservation.any_instance.stubs(:schedule_refund).returns(true)
    stub_active_merchant_interaction

    @transactable_with_all_days_booked_via_cancelled_rejected_expired_reservation = FactoryGirl.create(:transactable, quantity: 1)
    FactoryGirl.build(:future_reservation, transactable: @transactable_with_all_days_booked_via_cancelled_rejected_expired_reservation, state: 'confirmed').tap do |r|
      r.payment = FactoryGirl.build(:authorized_payment, payable: r)
      r.add_period(@date_start + 1.days)
      r.add_period(@date_start + 2.days)
      r.save!
    end.host_cancel!
    FactoryGirl.build(:future_reservation, transactable: @transactable_with_all_days_booked_via_cancelled_rejected_expired_reservation, state: 'confirmed').tap do |r|
      r.payment = FactoryGirl.build(:authorized_payment, payable: r)
      r.add_period(@date_start + 1.days)
      r.add_period(@date_start + 2.days)
      r.save!
    end.user_cancel!
    FactoryGirl.build(:future_reservation, transactable: @transactable_with_all_days_booked_via_cancelled_rejected_expired_reservation, state: 'unconfirmed').tap do |r|
      r.payment = FactoryGirl.build(:authorized_payment, payable: r)
      r.add_period(@date_start + 1.days)
      r.add_period(@date_start + 2.days)
      r.save!
    end.reject!
    FactoryGirl.build(:future_reservation, transactable: @transactable_with_all_days_booked_via_cancelled_rejected_expired_reservation, state: 'unconfirmed').tap do |r|
      r.payment = FactoryGirl.build(:authorized_payment, payable: r)
      r.add_period(@date_start + 1.days)
      r.add_period(@date_start + 2.days)
      r.save!
    end.expire!
  end
end
