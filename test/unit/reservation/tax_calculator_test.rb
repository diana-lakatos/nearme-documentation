require 'test_helper'

class Reservation::TaxCalculatorTest < ActiveSupport::TestCase

  setup do
    @tax_region = FactoryGirl.create(:tax_region)
    # tax rate 23%, included
    @tax_rate = FactoryGirl.create(:_tax_rate, tax_region: @tax_region)
    @reservation = FactoryGirl.build(:reservation_without_payment)
    @tli = FactoryGirl.build(:transactable_line_item, line_itemable: @reservation)
    FactoryGirl.create(:california_state_tax_rate, tax_region: @tax_region)
  end

  should "calculate included tax for country" do
    check_tax(23, 0)
  end

  should 'calculate included tax for state' do
    Address.any_instance.stubs(:state_object).returns(State.find_by_abbr("CA"))
    check_tax(13, 0)
  end

  context 'tax added' do

    setup do
      TaxRate.update_all included_in_price: false
    end

    should "calculate not included tax for country" do
      check_tax(0, 23)
    end

    should 'calculate not included tax for state' do
      Address.any_instance.stubs(:state_object).returns(State.find_by_abbr("CA"))
      check_tax(0, 13)
    end
  end

  def check_tax(included_rate, additional_rate)
    @tli.send(:calculate_tax)
    assert_equal included_rate, @tli.included_tax_total_rate
    assert_equal tax_included_in(@tli.unit_price_cents, included_rate), @tli.included_tax_price_cents.round(2)

    assert_equal additional_rate, @tli.additional_tax_total_rate
    assert_equal tax_additional_in(@tli.unit_price_cents, additional_rate), @tli.additional_tax_price_cents.round(2)
  end


  def tax_included_in(amount, percent)
    ((0.01 * percent * amount) / (1 + 0.01 * percent)).round(2)
  end


  def tax_additional_in(amount, percent)
    (0.01 * percent * amount).round(2)
  end

end
