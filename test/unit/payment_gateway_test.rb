require 'test_helper'

class PaymentGatewayTest < ActiveSupport::TestCase

  SUCCESS_RESPONSE = {"paid_amount"=>"10.00"}
  FAILURE_RESPONSE = {"paid_amount"=>"10.00", "error"=>"fail"}

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

  context 'payments' do
    setup do
      @user = FactoryGirl.create(:user)
      @payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
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
      @merchant_account = MerchantAccount::PaypalAdaptiveMerchantAccount.create(
        payment_gateway: @payout_gateway,
        merchantable: @payment_transfer.company,
        state: 'verified',
        email: 'email@example.com'
      )
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

