require 'test_helper'

class TransactableTypeTest < ActiveSupport::TestCase

  context 'pricing_options_long_period_names' do
    should 'return only active long term names' do
      assert_equal(%w(weekly monthly), FactoryGirl.build(:transactable_type, action_hourly_booking: false, action_daily_booking: false, action_weekly_booking: true, action_monthly_booking: true).pricing_options_long_period_names)
    end
  end

  context 'pricing_validation_is_correct' do
    setup do
      @transactable_type = TransactableType.first
    end

    should 'be valid if max is greater than min' do
      @transactable_type.min_daily_price_cents = 1
      @transactable_type.max_daily_price_cents = 9
      assert @transactable_type.valid?, "expected valid, but errors were found: #{@transactable_type.errors.to_json}"
    end

    should 'not be valid if min is lower than 0' do
      @transactable_type.min_daily_price_cents = -1
      @transactable_type.max_daily_price_cents = nil
      refute @transactable_type.valid?
    end

    should 'be valid if min is 0' do
      @transactable_type.min_daily_price_cents = 0
      @transactable_type.max_daily_price_cents = nil
      assert @transactable_type.valid?
    end

    should 'be valid if max is equal to max price' do
      @transactable_type.max_daily_price_cents = TransactableType::MAX_PRICE
      assert @transactable_type.valid?
    end

    should 'not be valid if max is greater than max price' do
      @transactable_type.max_daily_price_cents = TransactableType::MAX_PRICE+1
      refute @transactable_type.valid?
    end

    should 'be valid if min and max are nil' do
      @transactable_type.min_daily_price_cents = nil
      @transactable_type.max_daily_price_cents = nil
      assert @transactable_type.valid?
    end

    should 'not be valid if min is greater than max' do
      @transactable_type.min_daily_price_cents = 10
      @transactable_type.max_daily_price_cents = 9
      refute @transactable_type.valid?
    end

    should 'be valid if daily min is greater than weekly max' do
      @transactable_type.min_daily_price_cents = 10
      @transactable_type.max_weekly_price_cents = 9
      assert @transactable_type.valid?
    end

  end

  context 'availability rules settings' do

    should "create new transcactable type attribute for confirm reservations with public true and default value true" do
      transactable_type = FactoryGirl.create(:transactable_type)
      tta = transactable_type.custom_attributes.find { |attr| attr.name == "confirm_reservations" }
      assert_not_nil tta
      assert_equal "t", tta.default_value
      assert_equal "boolean", tta.attribute_type
      assert_equal "switch", tta.html_tag
      assert_equal(TransactableType.mandatory_boolean_validation_rules, tta.validation_rules)
      assert tta.public
    end

    should "create new transcactable type attribute for confirm reservations with public false and default value false" do
      transactable_type = FactoryGirl.create(:transactable_type, availability_options: { "confirm_reservations" => { "default_value" => false, "public" => false } })
      tta = transactable_type.custom_attributes.find { |attr| attr.name == "confirm_reservations" }
      assert_not_nil tta
      assert_equal "f", tta.default_value
      refute tta.public
    end

    context 'validation' do

      should 'be valid if all is set' do
        assert FactoryGirl.build(:transactable_type, availability_options: { "confirm_reservations" => { "default_value" => false, "public" => false } }).valid?
      end

      should 'not be valid if default value is not set' do
        refute FactoryGirl.build(:transactable_type, availability_options: { "confirm_reservations" => { "default_value" => nil, "public" => false } }).valid?
      end

      should 'not be valid if public is not set' do
        refute FactoryGirl.build(:transactable_type, availability_options: { "confirm_reservations" => { "default_value" => true, "public" => nil } }).valid?
      end

      should 'not be valid if options are not set at all' do
        refute FactoryGirl.build(:transactable_type, availability_options: nil).valid?
      end

      should 'not be valid if options do not contain confirm reservations' do
        refute FactoryGirl.build(:transactable_type, availability_options: { "confirm_reservations" => nil}).valid?
      end

    end
  end

  context '#booking_choices' do
    setup do
      @transactable_type = TransactableType.first
    end

    should "include regular if hourly, daily, weekly, monthly or free action is enabled" do
      @transactable_type.action_daily_booking = true
      assert(@transactable_type.booking_choices.include?('regular'))
    end

    should "define enabled methods" do
      TransactableType::BOOKING_TYPES.each do |bt|
        assert(@transactable_type.respond_to?("#{bt}_booking_enabled?"))
      end
    end
  end
end
