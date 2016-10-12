require 'test_helper'

class Transactable::TimeBasedBookingTest < ActiveSupport::TestCase
  setup do
    @action = FactoryGirl.build(:time_based_booking, transactable_type_action_type: nil)
    @action.transactable.action_type = @action
  end

  context '#prices_by_days' do
    should 'be correct for all prices' do
      mock_action_prices([{ price: 100, unit: 'day', number_of_units: 1 }, { price: 400, unit: 'day', number_of_units: 7 }, { price: 1200, unit: 'day', number_of_units: 20 }])
      assert_equal({ 1 => { price: 100 }, 7 => { price: 400 }, 20 => { price: 1200 } }, @action.prices_by_days)
      mock_action_prices([{ price: 100, unit: 'day', number_of_units: 1 }, { price: 400, unit: 'day', number_of_units: 7 }])
      assert_equal({ 1 => { price: 100 }, 7 => { price: 400 } }, @action.prices_by_days)
      mock_action_prices([{ price: nil, unit: 'day', number_of_units: 1, is_free_booking: true }])
      assert_equal({ 1 => { price: nil } }, @action.prices_by_days)
    end
  end

  context 'first available date' do
    should 'return right first date' do
      saturday = Time.zone.today.sunday + 6.days
      travel_to saturday.beginning_of_day do
        assert_equal saturday + 2.day, @action.first_available_date
      end
      sunday = Time.zone.today.sunday
      travel_to sunday.beginning_of_day do
        assert_equal sunday + 1.day, @action.first_available_date
      end
      tuesday = Time.zone.today.sunday + 2
      travel_to tuesday.beginning_of_day do
        assert_equal tuesday, @action.first_available_date
      end
    end
  end

  def set_action_prices(options = [])
    @action.pricings = options.map { |o| FactoryGirl.build(:transactable_pricing, o) }
  end

  def mock_action_prices(options = [])
    pricings = options.map do |option|
      option["#{option[:unit]}_booking?"] = true
      option[:units_and_price] = [option[:number_of_units], option.slice(:price)]
      stub(option)
    end
    @action.stubs(:pricings).returns(pricings)
  end
end
