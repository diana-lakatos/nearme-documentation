require 'test_helper'

class ReservationRequestTest < ActiveSupport::TestCase

  context 'payment method' do

    should 'use correct payment_method' do
      @listing = FactoryGirl.create(:transactable, :name => "blah", currency: "USD")
      @user = FactoryGirl.create(:user, name: "Firstname Lastname")
      stub_active_merchant_interaction

      {stripe_payment_gateway: "credit_card", manual_payment_gateway: "manual"}.each do |payment_gateway_name, payment_method_type|
        payment_gateway = FactoryGirl.create(payment_gateway_name)
        payment_method = payment_gateway.payment_methods.where(payment_method_type: payment_method_type).first
        attributes = {
          dates: [@listing.first_available_date.to_s(:db)],
          payment_method_id: payment_method.id
        }
        reservation_request = ReservationRequest.new(@listing, @user, PlatformContext.current, attributes)
        assert_equal payment_method_type, reservation_request.payment_method.payment_method_type
        assert_equal payment_gateway, reservation_request.payment_method.payment_gateway
      end
    end

  end

  context 'credit card' do
    setup do
      @listing = FactoryGirl.create(:transactable, :name => "blah")
      @user = FactoryGirl.create(:user, name: "Firstname Lastname")
      @date = @listing.first_available_date

      @stripe_payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
      @manual_payment_gateway = FactoryGirl.create(:manual_payment_gateway)

      @attributes = {
        dates: [@date.to_s(:db)],
        payment_method_id: @stripe_payment_gateway.payment_methods.first.id,
        card_number: 4242424242424242,
        card_exp_month: '05',
        card_exp_year: '2020',
        card_code: "411"
      }

      @reservation_request = ReservationRequest.new(@listing, @user, PlatformContext.current, @attributes)

      stub_active_merchant_interaction
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
          @attributes.merge!({ payment_method_id: @stripe_payment_gateway.payment_methods.first.id })
          @reservation_request = ReservationRequest.new(@listing, @user, PlatformContext.current, @attributes)
          assert_equal "credit_card", @reservation_request.payment_method.payment_method_type
        end

        should 'set manual' do
          @attributes.merge!({ payment_method_id: @manual_payment_gateway.payment_methods.first.id })
          @reservation_request = ReservationRequest.new(@listing, @user, PlatformContext.current, @attributes)
          assert_equal "manual", @reservation_request.payment_method.payment_method_type
        end
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
            reservation_request = ReservationRequest.new(nil, @user, PlatformContext.current, @attributes)
            assert !reservation_request.valid?
          end
        end

        context "no user" do
          should "be invalid" do
            reservation_request = ReservationRequest.new(@listing, nil, PlatformContext.current, @attributes)
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
            assert @reservation_request.process, @reservation_request.reservation.errors.inspect
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

  end

end
