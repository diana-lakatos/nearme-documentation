require 'test_helper'

class ReservationRequestTest < ActiveSupport::TestCase

  context 'payment method' do

    setup do
      @listing = FactoryGirl.create(:transactable, :name => "blah")
      @user = FactoryGirl.create(:user, name: "Firstname Lastname")
      @date = @listing.first_available_date
      @attributes = {
        :dates => [@date.to_s(:db)],
        payment_method: 'manual'
      }
      stub_billing_gateway(@listing.instance)
      stub_active_merchant_interaction
      Instance.any_instance.stubs(:payment_gateway).returns(FactoryGirl.create(:stripe_payment_gateway))
    end

    should 'ask for credit card details if manual payment disabled' do
      PlatformContext.current.instance.update_attribute(:possible_manual_payment, false)
      reservation_request = ReservationRequest.new(@listing, @user, PlatformContext.current, @attributes)
      refute reservation_request.valid?
      assert_equal 'credit_card', reservation_request.payment_method
    end

    should 'make reservation if manual payment enabled' do
      PlatformContext.current.instance.update_attribute(:possible_manual_payment, true)
      reservation_request = ReservationRequest.new(@listing, @user, PlatformContext.current, @attributes)
      assert_equal 'manual', reservation_request.payment_method
      assert reservation_request.valid?
    end
  end

  context 'credit card' do
    setup do
      @listing = FactoryGirl.create(:transactable, :name => "blah")
      @user = FactoryGirl.create(:user, name: "Firstname Lastname")
      @date = @listing.first_available_date
      @attributes = {
        :dates => [@date.to_s(:db)],
        :card_number => 4242424242424242,
        card_exp_month: '05',
        card_exp_year: '2020',
        :card_code => "411"
      }
      stub_billing_gateway(@listing.instance)
      stub_active_merchant_interaction
      @instance = Instance.first || create(:instance)
      @reservation_request = ReservationRequest.new(@listing, @user, PlatformContext.new(@instance), @attributes)
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
          Instance.any_instance.stubs(:payment_gateway).returns(FactoryGirl.create(:stripe_payment_gateway))
          @reservation_request = ReservationRequest.new(@listing, @user, PlatformContext.new(@instance), @attributes)
          assert_equal @reservation_request.payment_method, Reservation::PAYMENT_METHODS[:credit_card]
        end

        should 'set manual' do
          Instance.any_instance.stubs(:payment_gateway).returns(nil)
          @reservation_request = ReservationRequest.new(@listing, @user, PlatformContext.new(@instance), @attributes)
          assert_equal Reservation::PAYMENT_METHODS[:manual], @reservation_request.payment_method
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
            reservation_request = ReservationRequest.new(nil, @user, PlatformContext.new(@instance), @attributes)
            assert !reservation_request.valid?
          end
        end

        context "no user" do
          should "be invalid" do
            reservation_request = ReservationRequest.new(@listing, nil, PlatformContext.new(@instance), @attributes)
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

end
