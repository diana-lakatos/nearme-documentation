require 'test_helper'

class AvailabilityRuleTest < ActiveSupport::TestCase
  context "#open_at?" do
    setup do
      @availability_rule = AvailabilityRule.new(:open_hour => 6, :open_minute => 15, :close_hour => 17, :close_minute => 15)
    end

    should "return true during times of opening" do
      assert @availability_rule.open_at?(6, 15)
      assert @availability_rule.open_at?(6, 50)
      assert @availability_rule.open_at?(12, 0)
      assert @availability_rule.open_at?(17, 14)
    end

    should "return false during times closed" do
      assert !@availability_rule.open_at?(17, 15)
      assert !@availability_rule.open_at?(20, 0)
      assert !@availability_rule.open_at?(5, 0)
    end
  end

  context "templates" do
    setup do
      @object = Location.new
    end

    context "applying" do
      should "clear previous availability rules" do
        rule = AvailabilityRule.new(:day => 6, :open_hour => 20, :open_minute => 0, :close_hour => 23, :close_minute => 59)
        @object.availability_rules << rule
        assert @object.availability.open_on?(:day => 6, :hour => 22)

        @object.availability_template_id = 'M-F9-5'
        assert rule.marked_for_destruction?
        assert !@object.availability.open_on?(:day => 6, :hour => 22)
      end
    end

    context "M-F9-5" do
      setup do
        @object.availability_template_id = 'M-F9-5'
      end

      should "have correct availability" do
        assert @object.availability.open_on?(:day => 1, :hour => 9)
        assert @object.availability.open_on?(:day => 1, :hour => 16, :minute => 59)
        assert @object.availability.open_on?(:day => 2, :hour => 9)
        assert @object.availability.open_on?(:day => 3, :hour => 9)
        assert @object.availability.open_on?(:day => 4, :hour => 9)
        assert @object.availability.open_on?(:day => 5, :hour => 9)
        assert !@object.availability.open_on?(:day => 5, :hour => 17)
        assert !@object.availability.open_on?(:day => 6, :hour => 9)
        assert !@object.availability.open_on?(:day => 0, :hour => 9)
        assert_equal 'M-F9-5', @object.availability_template_id
      end
    end

    context "M-S9-5" do
      setup do
        @object.availability_template_id = 'M-S9-5'
      end

      should "have correct availability" do
        assert @object.availability.open_on?(:day => 1, :hour => 9)
        assert @object.availability.open_on?(:day => 1, :hour => 16, :minute => 59)
        assert @object.availability.open_on?(:day => 2, :hour => 9)
        assert @object.availability.open_on?(:day => 3, :hour => 9)
        assert @object.availability.open_on?(:day => 4, :hour => 9)
        assert @object.availability.open_on?(:day => 5, :hour => 9)
        assert @object.availability.open_on?(:day => 6, :hour => 9)
        assert !@object.availability.open_on?(:day => 6, :hour => 17)
        assert !@object.availability.open_on?(:day => 0, :hour => 9)
        assert_equal 'M-S9-5', @object.availability_template_id
      end
    end

    context "M-F8-6" do
      setup do
        @object.availability_template_id = 'M-F8-6'
      end

      should "have correct availability" do
        assert @object.availability.open_on?(:day => 1, :hour => 8)
        assert @object.availability.open_on?(:day => 1, :hour => 17, :minute => 59)
        assert @object.availability.open_on?(:day => 2, :hour => 8)
        assert @object.availability.open_on?(:day => 3, :hour => 8)
        assert @object.availability.open_on?(:day => 4, :hour => 8)
        assert @object.availability.open_on?(:day => 5, :hour => 8)
        assert !@object.availability.open_on?(:day => 5, :hour => 18)
        assert !@object.availability.open_on?(:day => 6, :hour => 8)
        assert !@object.availability.open_on?(:day => 0, :hour => 8)
        assert_equal 'M-F8-6', @object.availability_template_id
      end
    end

  end
end
