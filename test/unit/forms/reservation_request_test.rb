require 'test_helper'

class ReservationRequestTest < ActiveSupport::TestCase

  setup do
    @listing = FactoryGirl.create(:listing, :name => "blah")
    @user = FactoryGirl.create(:user)
    @date = Date.today + 1.day
    @attributes = {
      :dates => [@date.to_s(:db)]
    }
    @reservation_request = ReservationRequest.new(@listing, @user, @attributes)
  end

  context "#initialize" do
    should "build reservation" do
      assert_equal @reservation_request.reservation.class, Reservation
    end

    should "set user" do
      assert_equal @reservation_request.user, @user
    end

    should "set listing" do
      assert_equal @reservation_request.listing, @listing
    end

    should "add periods" do
      assert !@reservation_request.reservation_periods.empty?
    end
  end

  context "validations" do
    context "valid arguments" do
      should "be valid" do
        assert @reservation_request.valid?
      end
    end

    context "invalid arguments" do
      context "no listing" do
        should "be invalid" do
          reservation_request = ReservationRequest.new(nil, @user, @attributes)
          assert !reservation_request.valid?
        end
      end

      context "no user" do
        should "be invalid" do
          reservation_request = ReservationRequest.new(@listing, nil, @attributes)
          assert !reservation_request.valid?
        end
      end

      context "no reservation" do
        setup do
          @reservation_request.stubs(:reservation).returns(nil)
        end
        should "be invalid" do
          assert !@reservation_request.valid?
        end
      end
    end
  end

  context "#process" do
    context "valid" do
      context "no problems with saving reservation" do
        should "return true" do
          assert @reservation_request.process
        end
      end

      context "something went wrong when saving reservation" do
        setup do
          @reservation_request.stubs(:save_reservation).returns(false)
        end
        should "return false" do
          assert !@reservation_request.process
        end
      end
    end

    context "invalid" do
      setup do
        @reservation_request.stubs(:valid?).returns(false)
      end
      should "return false" do
        assert !@reservation_request.process
      end
    end
  end

  context "#reservation_periods" do
    should "return proper values" do
      assert_equal @reservation_request.reservation_periods.map { |rp| rp.date }, [@date]
    end
  end

  context "#display_phone_and_country_block?" do
    context "country_name is blank" do
      setup do
        @user.stubs(:country_name).returns(nil)
      end
      should "return true" do
        assert @reservation_request.display_phone_and_country_block?
      end
    end

    context "phone is blank" do
      setup do
        @user.stubs(:phone).returns(nil)
      end
      should "return true" do
        assert @reservation_request.display_phone_and_country_block?
      end
    end

    context "country_name and phone are set" do
      should "return false" do
        assert !@reservation_request.display_phone_and_country_block?
      end
    end
  end

end