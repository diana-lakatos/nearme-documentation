require 'test_helper'

class RecurringBookingRequestTest < ActiveSupport::TestCase

  setup do
    @listing = FactoryGirl.create(:transactable, :name => "blah")
    @user = FactoryGirl.create(:user, name: "Firstname Lastname")
    @first_monday = Time.zone.now.next_week
    @last_thursday = (Time.zone.now + 3.weeks).next_week + 3.days

    @attributes = {
      schedule_params: "{\"validations\":{\"day\":[1, 5]}, \"rule_type\":\"IceCube::WeeklyRule\", \"interval\":1, \"week_start\":0}",
      start_on: @first_monday,
      end_on: @last_thursday,
      quantity: 1,
      card_number: 4242424242424242,
      card_expires: "05/2020",
      card_code: "411"
    }
    stub_billing_gateway(@listing.instance)
    stub_active_merchant_interaction
    @recurring_booking_request = RecurringBookingRequest.new(@listing, @user, PlatformContext.new, @attributes)
  end

  context "#initialize" do

    should "set user" do
      assert_equal @recurring_booking_request.user, @user
    end

    should "set listing" do
      assert_equal @recurring_booking_request.listing, @listing
    end

    should "add proper reservations" do
      assert !@recurring_booking_request.recurring_booking.reservations.empty?
    end

    context 'determine payment method' do

      should 'set credit card' do
        Billing::Gateway::Incoming.any_instance.stubs(:possible?).returns(true)
        assert_equal @recurring_booking_request.payment_method, Reservation::PAYMENT_METHODS[:credit_card]
      end

      should 'set manual' do
        Billing::Gateway::Incoming.any_instance.stubs(:possible?).returns(false)
        assert_equal @recurring_booking_request.payment_method, Reservation::PAYMENT_METHODS[:manual]
      end
    end
  end

  context "validations" do
    context "valid arguments" do
      should "be valid" do
        assert @recurring_booking_request.valid?
      end
    end

    context "invalid arguments" do
      context "no listing" do
        should "be invalid" do
          recurring_booking_request = RecurringBookingRequest.new(nil, @user, PlatformContext.new, @attributes)
          assert !recurring_booking_request.valid?
        end
      end

      context "no user" do
        should "be invalid" do
          recurring_booking_request = RecurringBookingRequest.new(@listing, nil, PlatformContext.new, @attributes)
          assert !recurring_booking_request.valid?
        end
      end

      context "no recurring_booking" do

        setup do
          @recurring_booking_request.stubs(:recurring_booking).returns(nil)
        end

        should "be invalid" do
          assert !@recurring_booking_request.valid?
        end

      end
    end
  end

  context "#process" do
    context "valid" do
      context "no problems with saving recurring_booking" do
        should "return true" do
          assert_difference 'Reservation.count', 7 do
            assert @recurring_booking_request.process, @recurring_booking_request.errors.full_messages
          end
        end
      end

      should "if one reservation is invalid, should not save the rest" do

        @listing.stubs(:available_on?).with do |date, quantity, minute_start, minute_end|
          date != @first_monday.to_date + 14.days
        end.at_least(0).returns(true)
        @listing.stubs(:available_on?).with do |date, quantity, minute_start, minute_end|
          date == @first_monday.to_date + 14.days
        end.returns(false)
        assert_difference 'Reservation.count', 6 do
          assert @recurring_booking_request.process, @recurring_booking_request.errors.full_messages
        end
      end

      context "something went wrong when saving recurring_booking" do
        setup do
          @recurring_booking_request.stubs(:save_reservations).returns(false)
        end

        should "return false" do
          assert_no_difference 'Reservation.count' do
            assert !@recurring_booking_request.process
          end
        end
      end
    end

    context "invalid" do
      setup do
        @recurring_booking_request.stubs(:valid?).returns(false)
      end
      should "return false" do
        assert !@recurring_booking_request.process
      end
    end
  end

  context "#recurring_booking_periods" do
    should "return proper values" do
      monday = @first_monday.to_date
      assert_equal [monday, monday + 4.days, monday + 7.days, monday + 11.days, monday + 14.days, monday + 18.days, monday + 21.days], @recurring_booking_request.dates.sort
    end

    should 'create no more than 50 reservations' do
      @attributes = {
        schedule_params: "{\"validations\":{\"day\":[1, 5]}, \"rule_type\":\"IceCube::WeeklyRule\", \"interval\":1, \"week_start\":0}",
        start_on: @first_monday,
        end_on: @last_thursday + 50.years,
        quantity: 1,
        card_number: 4242424242424242,
        card_expires: "05/2020",
        card_code: "411"
      }
      @recurring_booking_request = RecurringBookingRequest.new(@listing, @user, PlatformContext.new, @attributes)
      assert_equal 50, @recurring_booking_request.dates.count
      assert_equal 50, @recurring_booking_request.recurring_booking.reservations.size
    end
  end

  context "#display_phone_and_country_block?" do
    context "country_name is blank" do
      setup do
        @user.stubs(:country_name).returns(nil)
      end
      should "return true" do
        assert @recurring_booking_request.display_phone_and_country_block?
      end
    end

    context "phone is blank" do
      setup do
        @user.stubs(:phone).returns(nil)
      end
      should "return true" do
        assert @recurring_booking_request.display_phone_and_country_block?
      end
    end

    context "country_name and phone are set" do
      should "return false" do
        assert !@recurring_booking_request.display_phone_and_country_block?
      end
    end
  end

end
