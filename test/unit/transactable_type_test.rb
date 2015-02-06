require 'test_helper'

class TransactableTypeTest < ActiveSupport::TestCase

  context 'pricing options' do

    should 'return only active pricing options' do
      assert_equal({"daily" => "1", "monthly" => "1"}, FactoryGirl.build(:transactable_type, pricing_options: {"daily" => "1", "weekly" => "0", "monthly" => "1"}).pricing_options)
    end

    context 'pricing_options_long_period_names' do
      should 'return only active long term names' do
        assert_equal(%w(weekly monthly), FactoryGirl.build(:transactable_type, pricing_options: {"daily" => "0", "free" => "1", "hourly" => "1", "weekly" => "1", "monthly" => "1"}).pricing_options_long_period_names)
      end
    end
  end

  context 'pricing_validation_is_correct' do
    setup do
      @transactable_type = TransactableType.first
    end
    should 'be valid if max is greater than min' do
      @transactable_type.pricing_validation = { "daily" => { "min" => "1", "max" => "9" } }
      assert @transactable_type.valid?, "expected valid, but errors were found: #{@transactable_type.errors.to_json}"
    end

    should 'not be valid if min is lower than 0' do
      @transactable_type.pricing_validation = { "daily" => { "min" => "-1" } }
      refute @transactable_type.valid?
    end

    should 'be valid if min is 0' do
      assert FactoryGirl.build(:transactable_type, :pricing_validation => { "daily" => { "min" => "0" } }).valid?
    end

    should 'be valid if max is equal to max price' do
      assert FactoryGirl.build(:transactable_type, :pricing_validation => { "daily" => { "max" => "#{TransactableType::MAX_PRICE}" } }).valid?
    end

    should 'not be valid if max is greater than max price' do
      refute FactoryGirl.build(:transactable_type, :pricing_validation => { "daily" => { "max" => "#{TransactableType::MAX_PRICE+1}" } }).valid?
    end

    should 'be valid if min and max are nil' do
      assert FactoryGirl.build(:transactable_type, :pricing_validation => { "daily" => { "min" => nil, "max" => nil } }).valid?
    end

    should 'not be valid if min is greater than max' do
      refute FactoryGirl.build(:transactable_type, :pricing_validation => { "daily" => { "min" => "10", "max" => "9" } }).valid?
    end

    should 'be valid if daily min is greater than weekly max' do
      assert FactoryGirl.build(:transactable_type, :pricing_validation => { "daily" => { "min" => "10" }, "weekly" => { "max" => "9" } }).valid?
    end

  end

  context 'build_validation_rule_for' do

    setup do
      @expected_hash = { :greater_than_or_equal_to => 0, :less_than_or_equal_to => TransactableType::MAX_PRICE } }
    end

    should 'populate default restrictions if nothing is provide' do
      assert_equal @expected_hash, FactoryGirl.build(:transactable_type).build_validation_rule_for("daily")
    end

    should 'not use daily for hourly' do
      transactable_type = FactoryGirl.build(:transactable_type, :pricing_validation => { "daily" => { "min" => "342" } })
      assert_equal @expected_hash, transactable_type.build_validation_rule_for("hourly")
    end

    should 'populate custom min restriction if nothing populated for key ' do
      transactable_type = FactoryGirl.build(:transactable_type, :pricing_validation => { "daily" => { "min" => "342" } })
      transactable_type.build_validation_rule_for("daily")
      @expected_hash[:numericality][:redirect] = "monthly_price"
      assert_equal @expected_hash, transactable_type.build_validation_rule_for("monthly")
    end

    should 'populate custom max restriction if available and default min' do
      transactable_type = FactoryGirl.build(:transactable_type, :pricing_validation => { "daily" => { "max" => "123" } })
      @expected_hash[:numericality][:less_than_or_equal_to] = 123
      assert_equal @expected_hash, transactable_type.build_validation_rule_for("daily")
    end

    should 'populate custom max and min if available' do
      transactable_type = FactoryGirl.build(:transactable_type, :pricing_validation => { "daily" => { "max" => "123", "min" => "88" } })
      @expected_hash[:numericality][:less_than_or_equal_to] = 123
      @expected_hash[:numericality][:greater_than_or_equal_to] = 88
      assert_equal @expected_hash, transactable_type.build_validation_rule_for("daily")
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
end
