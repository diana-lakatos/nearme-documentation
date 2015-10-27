require 'test_helper'

class PaymentGatewayTest < ActiveSupport::TestCase
  validate_presence_of(:payment_gateway_id)
  validate_presence_of(:test_settings)
  validate_presence_of(:live_settings)

  should belong_to(:instance)
  should belong_to(:payment_gateway)

  setup do
    stub_active_merchant_interaction({success?: true, params: SUCCESS_RESPONSE })
  end

  should 'get proper payment gateway from instance' do
    @stripe = FactoryGirl.create(:stripe_payment_gateway)
    @stripe.payment_countries = [Country.find_by_iso("PL") || FactoryGirl.create(:country_pl)]
    @paypal = FactoryGirl.create(:paypal_payment_gateway)
    @paypal.payment_countries = [Country.find_by_iso("GB") || FactoryGirl.create(:country_gb)]
    @fetch = FactoryGirl.create(:fetch_payment_gateway)
    @braintree = FactoryGirl.create(:braintree_payment_gateway)
    @instance = PlatformContext.current.instance

    assert_equal @stripe, @instance.payment_gateway('PL', 'USD')
    assert_equal @paypal, @instance.payment_gateway('GB', 'USD')
    assert_equal @fetch, @instance.payment_gateway('NZ', 'NZD')
    assert_equal @braintree, @instance.payment_gateway('US', 'USD')

    # check supported currency
    assert_nil @instance.payment_gateway('NZ', 'USD')
    # ignore if country has nothing assigned
    assert_nil @instance.payment_gateway('RU', 'USD')
  end

  SUCCESS_RESPONSE = {"paid_amount"=>"10.00"}
  FAILURE_RESPONSE = {"paid_amount"=>"10.00", "error"=>"fail"}

  context 'payments' do
    setup do
      @user = FactoryGirl.create(:user)
      @payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
      @payment_method = @payment_gateway.payment_methods.first
    end

    context 'authorize' do
      setup do
        @transactable = FactoryGirl.create(:transactable)
        @reservation_request = ReservationRequest.new(
          @transactable,
          @user,
          PlatformContext.current,
          FactoryGirl.attributes_for(:reservation_request, payment_method: @payment_method)
        )
      end

      should "authorize when provided right details" do
        assert_equal("54533", @payment_gateway.authorize(@reservation_request))
        billing_authorization = BillingAuthorization.last
        assert billing_authorization.success?
        assert_equal @payment_gateway, billing_authorization.payment_gateway
        assert_equal(OpenStruct.new(authorization: "54533", success?: true, params: {"paid_amount"=>"10.00"}), billing_authorization.response)
      end

      should "not authorize when authorization response is not success" do
        stub_active_merchant_interaction({success?: false, message: "fail"})

        assert_equal(false, @payment_gateway.authorize(@reservation_request))
        billing_authorization = BillingAuthorization.last
        assert_equal true, @reservation_request.errors.present?
        assert_equal @payment_gateway, billing_authorization.payment_gateway
        assert_equal billing_authorization, @transactable.billing_authorizations.last
        assert_equal billing_authorization.success?, false
        assert_equal(billing_authorization.response, OpenStruct.new(authorization: "54533", success?: false, message: 'fail'))
      end
    end


    context 'authorize validation error' do
      should "not authorize when provided the wrong details" do
        @transactable = FactoryGirl.create(:transactable)
        @reservation_request = ReservationRequest.new(
          @transactable,
          @user,
          PlatformContext.current,
          FactoryGirl.attributes_for(:reservation_request_with_not_valid_cc, payment_method: @payment_gateway.payment_methods.first)
        )

        assert_equal(false, @payment_gateway.authorize(@reservation_request, {error: true}))
        assert_equal [I18n.t('buy_sell_market.checkout.invalid_cc')], @reservation_request.errors[:cc]
      end
    end

    context '#capture/#charge' do
      should 'create charge object when saving payment with successful billing_authorization' do

        reservation = FactoryGirl.create(:reservation_with_credit_card, user: @user)
        billing_authorization = FactoryGirl.create(:billing_authorization,
          reference: reservation,
          payment_gateway: @payment_gateway)

        payment = FactoryGirl.create(:payment_unpaid, payable: reservation.reload)
        charge = Charge.last
        assert_equal @user.id, charge.user_id
        assert_equal 110_00, charge.amount
        assert_equal 'USD', charge.currency
        assert_equal payment, charge.payment
        assert_equal SUCCESS_RESPONSE, charge.response.params
        assert_equal payment.paid?, true
        assert charge.success?
      end

      should 'fail' do
        stub_active_merchant_interaction({success?: false, params: FAILURE_RESPONSE })

        reservation = FactoryGirl.create(:reservation_with_credit_card, user: @user)
        billing_authorization = FactoryGirl.create(:billing_authorization,
          reference: reservation,
          payment_gateway: @payment_gateway,
          token: '2')
        payment = FactoryGirl.create(:payment_unpaid, payable: reservation.reload)

        charge = Charge.last
        assert_equal FAILURE_RESPONSE, charge.response.params
        assert_equal payment.paid?, false
        refute charge.success?
      end
    end

    context 'refund' do
      setup do
        @charge = FactoryGirl.create(:charge)
        @payment = @charge.payment
        @currency = 'JPY'
      end

      should 'create refund object when succeeded' do
        charge_params = { "id" => "3" }
        charge_response = ActiveMerchant::Billing::Response.new true, 'OK', charge_params
        @charge.update_attribute(:response, charge_response)
        refund = @payment_gateway.refund(1000, @currency, @payment, @charge)
        assert_equal 1000, refund.amount
        assert_equal 'JPY', refund.currency
        assert_equal SUCCESS_RESPONSE, refund.response.params
        assert_equal @payment, refund.payment
        assert refund.success?
      end

      should 'create refund object when failed' do
        stub_active_merchant_interaction({success?: false, params: FAILURE_RESPONSE })

        charge_params = { "id" => "2" }
        charge_response = ActiveMerchant::Billing::Response.new true, 'OK', charge_params
        @charge.update_attribute(:response, charge_response)
        refund = @payment_gateway.refund(1000, @currency, @payment, @charge)
        assert_equal 1000, refund.amount
        assert_equal 'JPY', refund.currency
        assert_equal FAILURE_RESPONSE, refund.response.params
        refute refund.success?
      end
    end
  end

  context "callbacks" do
    setup do
      @stripe = FactoryGirl.build(:stripe_payment_gateway)
      @paypal = FactoryGirl.build(:paypal_payment_gateway)
    end

    should "respond_to? country" do
      assert @stripe.respond_to?(:country)
    end

    should "set default values for live_settings and test_settings after find" do
      @stripe = FactoryGirl.create(:stripe_payment_gateway)
      @stripe.live_settings = ""
      assert_equal @stripe.live_settings, ""
      @stripe = PaymentGateway.find(@stripe.id)
      assert_equal @stripe.live_settings.class, Hash
      assert @stripe.live_settings.has_key?(:login)
    end
  end

  context 'payout' do

    setup do
      @payout_gateway = FactoryGirl.create(:paypal_adaptive_payment_gateway)
      @payout_gateway.payment_currencies << (Currency.find_by_iso_code("JPY") || FactoryGirl.create(:currency, iso_code: "JPY"))
      @payment_transfer = FactoryGirl.create(:payment_transfer_unpaid)
      @amount = Money.new(1234, 'JPY')
      @merchant_account = MerchantAccount::PaypalAdaptiveMerchantAccount.create(payment_gateway: @payout_gateway, merchantable: @payment_transfer.company, state: 'verified')
    end

    should 'create payout object when succeeded' do
      @payout_gateway.payout(@payment_transfer.company, {amount: @amount, reference: @payment_transfer})
      payout = Payout.last
      assert_equal 1234, payout.amount
      assert_equal 'JPY', payout.currency
      assert_equal @payment_transfer, payout.reference
      assert payout.success?
      refute payout.pending?
      refute payout.failed?
    end

    # should 'create payout object when payout' do
    #   @payout_gateway.payout(@payment_transfer.company, {amount: @amount, reference: @payment_transfer})
    #   payout = Payout.last
    #   assert_equal 1234, payout.amount
    #   assert_equal 'JPY', payout.currency
    #   assert payout.pending?
    #   refute payout.success?
    #   refute payout.failed?
    # end

    should 'create payout object when failed' do
      stub_active_merchant_interaction({success?: false})

      @payout_gateway.payout(@payment_transfer.company, {amount: @amount, reference: @payment_transfer})
      payout = Payout.last
      assert_equal 1234, payout.amount
      assert_equal 'JPY', payout.currency
      refute payout.success?
      refute payout.pending?
      assert payout.failed?
    end

    should 'be invoked with right arguments' do
      Payout.any_instance.stubs(:should_be_verified_after_time?).returns(false)
      @payout_gateway.expects(:process_payout).with do |merchant_account, payout_argument, reference|
        payout_argument == @amount
      end
      @payout_gateway.payout(@payment_transfer.company, {amount: @amount, reference: @payment_transfer})
    end
  end
end

