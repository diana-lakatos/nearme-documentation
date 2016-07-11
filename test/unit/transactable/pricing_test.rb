require 'test_helper'

class Transactable::PricingTest < ActiveSupport::TestCase

  setup do
    @pricing = FactoryGirl.build(:transactable_pricing)
  end

  context 'uniqueness validation' do
    should 'be invalid' do
      assert @pricing.save
      pricing2 = FactoryGirl.build(:transactable_pricing, action: @pricing.action, transactable_type_pricing: nil)
      refute pricing2.valid?
    end
  end

  context "free flag and prices" do

    should "valid if free flag is true and no price is provided" do
      @pricing.is_free_booking = true
      @pricing.price = nil
      assert @pricing.valid?
    end

    should "valid if free flag is false and at daily price is greater than zero" do
      @pricing.is_free_booking = false
      @pricing.price = 1
      assert @pricing.valid?
    end

    context 'instance observes min/max pricing constraints specified by instance admin' do
      setup do
        @pricing.is_free_booking = false
      end

      should 'be valid if hourly price within specified range' do
        @pricing.price_cents = 999_99
        assert @pricing.valid?, @pricing.errors.full_messages.join(', ')
        @pricing.price_cents = 99
        assert @pricing.valid?, @pricing.errors.full_messages.join(', ')
      end

      should 'be invalid if hourly price outside specified range' do
        @pricing.price_cents = 100_001
        refute @pricing.valid?
        @pricing.price_cents = 100
        assert @pricing.valid?, @pricing.errors.full_messages.join(', ')
      end

      should 'not be valid if hourly price is too low' do
        @pricing.transactable_type_pricing.min_price_cents = 100
        @pricing.price_cents = 1
        refute @pricing.valid?
        @pricing.price = 11
        assert @pricing.valid?, @pricing.errors.full_messages.join(', ')
      end

    end
  end

end
