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
          payment: {
            payment_method: payment_method
          }
        }
        reservation_request = ReservationRequest.new(@listing, @user, attributes)
        assert_equal payment_method_type, reservation_request.payment.payment_method.payment_method_type
        assert_equal payment_gateway, reservation_request.payment.payment_gateway
      end
    end
  end

  should "assign correct cancellation policies" do
    TransactableType.update_all({
      cancellation_policy_enabled: Time.zone.now,
      cancellation_policy_hours_for_cancellation: 48,
      cancellation_policy_penalty_percentage: 50})

    @reservation = FactoryGirl.build(:reservation)
    @listing = @reservation.listing
    @user = FactoryGirl.create(:user, name: "Firstname Lastname")
    @date = @listing.first_available_date
    @stripe_payment_gateway = FactoryGirl.create(:stripe_payment_gateway)

    @reservation_request = ReservationRequest.new(@listing, @user, attributes)
    @reservation_request.send(:set_cancellation_policy)
    assert_equal 48, @reservation_request.reservation.cancellation_policy_hours_for_cancellation
    assert_equal 50, @reservation_request.reservation.cancellation_policy_penalty_percentage
  end

  context 'credit card' do
    setup do
      @listing = FactoryGirl.create(:transactable, :name => "blah")
      @user = FactoryGirl.create(:user, name: "Firstname Lastname")
      @date = @listing.first_available_date

      @stripe_payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
      @manual_payment_gateway = FactoryGirl.create(:manual_payment_gateway)
      @reservation_request = ReservationRequest.new(@listing, @user, attributes)

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
          @reservation_request = ReservationRequest.new(@listing, @user, attributes)
          @reservation_request.payment.valid?
          assert @reservation_request.payment.credit_card_payment?
          assert !@reservation_request.payment.offline
        end

        should 'set manual' do
          attributes[:payment][:payment_method] = @manual_payment_gateway.payment_methods.manual.first
          @reservation_request = ReservationRequest.new(@listing, @user, attributes)
          @reservation_request.payment.valid?
          assert @reservation_request.payment.manual_payment?
          assert @reservation_request.payment.offline
        end
      end
    end

    context "validations" do
      context "valid arguments" do
        should "be valid" do
          assert @reservation_request.valid?
        end
      end

      should "raise error when total_price_check is incorrect" do
        @reservation_request.total_amount_check = @reservation_request.reservation.total_amount.cents
        assert @reservation_request.valid?
        @reservation_request.total_amount_check = 1 + @reservation_request.reservation.total_amount.cents
        refute @reservation_request.valid?
        error = I18n.t("activemodel.errors.models.reservation_request.attributes.base.total_amount_changed")
        assert_equal error, @reservation_request.errors.full_messages.to_sentence
      end

      context "invalid arguments" do
        context "no listing" do
          should "be invalid" do
            reservation_request = ReservationRequest.new(nil, @user, attributes)
            assert !reservation_request.valid?
          end
        end

        context "no user" do
          should "be invalid" do
            reservation_request = ReservationRequest.new(@listing, nil, attributes)
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

  def attributes
    @attributes ||= {
        dates: [@date.to_s(:db)],
        payment: {
          payment_method: @stripe_payment_gateway.payment_methods.first,
          credit_card_form: {
            first_name: "Albert",
            last_name: "Einstein",
            number: 4242424242424242,
            month: '05',
            year: '2020',
            verification_value: "411"
          }
        }
      }
  end
end
