require 'test_helper'

class Reservation::TaxCalculatorTest < ActiveSupport::TestCase

  setup do
    @tax_region = FactoryGirl.create(:tax_region)
    # tax rate 23%, included
    @tax_rate = FactoryGirl.create(:_tax_rate, tax_region: @tax_region)
    @reservation = FactoryGirl.build(:reservation_without_payment)
  end

  should "calculate included tax for country" do
    @reservation.send :calculate_prices
    @reservation.total_tax_amount_cents == tax_included_in(@reservation.total_amount_cents, 23)
  end

  should 'calculate included tax for state' do
    FactoryGirl.create(:california_state_tax_rate, tax_region: @tax_region)
    @reservation.send :calculate_prices
    @reservation.total_tax_amount_cents == tax_included_in(@reservation.total_amount_cents, 13)
  end

  context 'tax not included in price' do

    setup do
      @tax_rate.update_attributes included_in_price: false
    end

    should "calculate not included tax for country" do
      @reservation.send :calculate_prices
      @reservation.total_tax_amount_cents == 0
      @reservation.additional_charges.last.amount_cents == tax_added(@reservation.total_amount_cents, 23)
    end

    should 'calculate not included tax for state' do
      FactoryGirl.create(:california_state_tax_rate, tax_region: @tax_region, included_in_price: false)
      @reservation.send :calculate_prices
      @reservation.total_tax_amount_cents == 0
      @reservation.additional_charges.last.amount_cents == tax_added(@reservation.total_amount_cents, 13)
    end
  end


  def tax_included_in(amount, percent)
    ((0.01 * percent * amount) / (1 + 0.01 * percent)).to_i
  end


  def tax_added(amount, percent)
    (0.01 * percent * amount).to_i
  end

end
