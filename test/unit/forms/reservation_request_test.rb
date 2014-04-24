require 'test_helper'
require 'vcr_setup'

class ReservationRequestTest < ActiveSupport::TestCase

  setup do
    @listing = FactoryGirl.create(:transactable, :name => "blah")
    @user = FactoryGirl.create(:user, name: "Firstname Lastname")
    @date = @listing.first_available_date
    @attributes = {
      :dates => [@date.to_s(:db)],
      :card_number => 4242424242424242,
      :card_expires => "05/2020",
      :card_code => "411"
    }
    ipg = FactoryGirl.create(:stripe_instance_payment_gateway)

    @listing.instance.instance_payment_gateways << ipg

    country_ipg = FactoryGirl.create(
      :country_instance_payment_gateway, 
      country_alpha2_code: "US", 
      instance_payment_gateway_id: ipg.id
    )

    @listing.instance.country_instance_payment_gateways << country_ipg
    
    @reservation_request = ReservationRequest.new(@listing, @user, PlatformContext.new, @attributes)
  end

  context "#initialize" do
    should "build decorated reservation" do
      assert @reservation_request.reservation.is_a?(ReservationDecorator)
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

    context 'determine payment method' do
      should 'set credit card' do
        Billing::Gateway::Incoming.any_instance.stubs(:possible?).returns(true)
        assert_equal @reservation_request.payment_method, Reservation::PAYMENT_METHODS[:credit_card]
      end

      should 'set manual' do
        Billing::Gateway::Incoming.any_instance.stubs(:possible?).returns(false)
        assert_equal @reservation_request.payment_method, Reservation::PAYMENT_METHODS[:manual]
      end
    end
  end

  context "validations" do
    context "valid arguments" do
      should "be valid" do
        VCR.use_cassette('reservation_request_processing') do
          assert @reservation_request.valid?
        end
      end
    end

    context "invalid arguments" do
      context "no listing" do
        should "be invalid" do
          reservation_request = ReservationRequest.new(nil, @user, PlatformContext.new, @attributes)
          assert !reservation_request.valid?
        end
      end

      context "no user" do
        should "be invalid" do
          reservation_request = ReservationRequest.new(@listing, nil, PlatformContext.new, @attributes)
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
          VCR.use_cassette('reservation_request_processing') do
            assert @reservation_request.process, @reservation_request.reservation.errors.inspect
          end
        end
      end

      context "something went wrong when saving reservation" do
        setup do
          @reservation_request.stubs(:save_reservation).returns(false)
        end
        should "return false" do
          VCR.use_cassette('reservation_request_processing') do
            assert !@reservation_request.process
          end
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
