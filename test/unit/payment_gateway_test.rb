require 'test_helper'

class PaymentGatewayTest < ActiveSupport::TestCase
  validate_presence_of(:payment_gateway_id)
  validate_presence_of(:test_settings)
  validate_presence_of(:live_settings)

  should have_many(:country_payment_gateways)
  should belong_to(:instance)
  should belong_to(:payment_gateway)

  should 'get proper payment gateway from instance' do
    @stripe = FactoryGirl.create(:stripe_payment_gateway)
    @paypal = FactoryGirl.create(:paypal_payment_gateway)
    @fetch = FactoryGirl.create(:fetch_payment_gateway)
    @braintree = FactoryGirl.create(:braintree_payment_gateway)
    @instance = PlatformContext.current.instance
    FactoryGirl.create(:country_payment_gateway, country_alpha2_code: 'PL', payment_gateway: @stripe)
    FactoryGirl.create(:country_payment_gateway, country_alpha2_code: 'NZ', payment_gateway: @fetch)
    FactoryGirl.create(:country_payment_gateway, country_alpha2_code: 'EN', payment_gateway: @paypal)
    FactoryGirl.create(:country_payment_gateway, country_alpha2_code: 'US', payment_gateway: @braintree)

    assert_equal @stripe, @instance.payment_gateway('PL', 'USD')
    assert_equal @paypal, @instance.payment_gateway('EN', 'USD')
    assert_equal @fetch, @instance.payment_gateway('NZ', 'NZD')
    assert_equal @braintree, @instance.payment_gateway('US', 'USD')

    # check supported currency
    assert_nil @instance.payment_gateway('NZ', 'USD')
    # ignore if country has nothing assigned
    assert_nil @instance.payment_gateway('RU', 'USD')
  end

  class PaymentGateway::TestPaymentGateway < PaymentGateway
    class TestGateway

      def authorize(*args)
        if args[1] == "2"
          OpenStruct.new(success?: false, message: 'fail')
        else
          OpenStruct.new(success?: true, authorization: "a")
        end
      end

      def capture(*args)
        if args[1] == "2"
          OpenStruct.new(success?: false, params: FAILURE_RESPONSE)
        else
          OpenStruct.new(success?: true, params: SUCCESS_RESPONSE)
        end
      end

      def refund(*args)
        if args[1] == "2"
          OpenStruct.new(success?: false, params: FAILURE_RESPONSE)
        else
          OpenStruct.new(success?: true, params: SUCCESS_RESPONSE)
        end
      end
    end

    attr_accessor :success

    def gateway
      @gateway ||= TestGateway.new
    end

    def refund_identification(charge)
      charge.response.params["id"]
    end

  end

  SUCCESS_RESPONSE = {"paid_amount"=>"10.00"}
  FAILURE_RESPONSE = {"paid_amount"=>"10.00", "error"=>"fail"}

  setup do
    @user = FactoryGirl.create(:user)
    @test_processor = PaymentGateway::TestPaymentGateway.create!
  end

  context '#authorize' do
    should "authorize when provided right details" do
      assert_equal({token: 'a'}, @test_processor.authorize(1000, 'USD', "1"))
    end

    should "not authorize when provided the wrong details" do
      assert_equal({error: 'fail'}, @test_processor.authorize(1000, 'USD', "2"))
    end
  end

  context '#charge' do
    setup do
      @rc = FactoryGirl.create(:payment)
    end

    should 'create charge object' do
      @test_processor.charge(@user, 1000, 'USD', @rc, "53433")
      charge = Charge.last

      assert_equal @user.id, charge.user_id
      assert_equal 10_00, charge.amount
      assert_equal 'USD', charge.currency
      assert_equal @rc, charge.payment
      assert_equal SUCCESS_RESPONSE, charge.response.params
      assert charge.success?
    end

    should 'fail' do
      @test_processor.charge(@user, 1000, 'USD', @rc, "2")
      charge = Charge.last
      assert_equal FAILURE_RESPONSE, charge.response.params
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
      refund = @test_processor.refund(1000, @currency, @payment, @charge)
      assert_equal 1000, refund.amount
      assert_equal 'JPY', refund.currency
      assert_equal SUCCESS_RESPONSE, refund.response.params
      assert_equal @payment, refund.payment
      assert refund.success?
    end

    should 'create refund object when failed' do
      charge_params = { "id" => "2" }
      charge_response = ActiveMerchant::Billing::Response.new true, 'OK', charge_params
      @charge.update_attribute(:response, charge_response)
      refund = @test_processor.refund(1000, @currency, @payment, @charge)
      assert_equal 1000, refund.amount
      assert_equal 'JPY', refund.currency
      assert_equal FAILURE_RESPONSE, refund.response.params
      refute refund.success?
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

    should "set country settings after save" do
      @stripe.country = "US"
      assert_equal PlatformContext.current.instance.country_payment_gateways.count, 0
      @stripe.save!
      assert_equal PlatformContext.current.instance.country_payment_gateways.count, 1
      assert_equal PlatformContext.current.instance.country_payment_gateways.first.country_alpha2_code, "US"
      assert_equal PlatformContext.current.instance.country_payment_gateways.first.payment_gateway_id, @stripe.id
    end

    should "change gateway preference for country after save" do
      @stripe.country = "US"
      @stripe.save!
      assert_equal PlatformContext.current.instance.country_payment_gateways.count, 1
      assert_equal PlatformContext.current.instance.country_payment_gateways.first.country_alpha2_code, "US"
      assert_equal PlatformContext.current.instance.country_payment_gateways.first.payment_gateway_id, @stripe.id

      @paypal.country = "US"
      @paypal.save
      assert_equal PlatformContext.current.instance.country_payment_gateways.count, 1
      assert_equal PlatformContext.current.instance.country_payment_gateways.first.country_alpha2_code, "US"
      assert_equal PlatformContext.current.instance.country_payment_gateways.first.payment_gateway_id, @paypal.id
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

  class TestPayoutProcessor < PaymentGateway

    attr_accessor :success, :pending

    def process_payout(merchant_account, amount)
      if self.pending
        payout_pending('pending payout response')
      elsif self.success
        payout_successful('successful payout response')
      else
        payout_failed('failed payout response')
      end
    end

  end


  context 'payout' do

    setup do
      @test_processor = TestPayoutProcessor.create!
      @payment_transfer = FactoryGirl.create(:payment_transfer_unpaid)
      @amount = Money.new(1234, 'JPY')

      CountryPaymentGateway.delete_all
      FactoryGirl.create(:country_payment_gateway, payment_gateway: @test_processor, country_alpha2_code: 'US')
      FactoryGirl.create(:paypal_merchant_account, payment_gateway: @test_processor, merchantable: @payment_transfer.company)
    end

    should 'create payout object when succeeded' do
      @test_processor.success = true
      @test_processor.payout(@payment_transfer.company, {:amount => @amount, :reference => @payment_transfer})
      payout = Payout.last
      assert_equal 1234, payout.amount
      assert_equal 'JPY', payout.currency
      assert_equal @payment_transfer, payout.reference
      assert payout.success?
      refute payout.pending?
      refute payout.failed?
    end

    should 'create payout object when pending' do
      @test_processor.pending = true
      @test_processor.payout(@payment_transfer.company, {:amount => @amount, :reference => @payment_transfer})
      payout = Payout.last
      assert_equal 1234, payout.amount
      assert_equal 'JPY', payout.currency
      assert payout.pending?
      refute payout.success?
      refute payout.failed?
    end

    should 'create payout object when failed' do
      @test_processor.success = false
      @test_processor.payout(@payment_transfer.company, {:amount => @amount, :reference => @payment_transfer})
      payout = Payout.last
      assert_equal 1234, payout.amount
      assert_equal 'JPY', payout.currency
      refute payout.success?
      refute payout.pending?
      assert payout.failed?
    end

    should 'be invoked with right arguments' do
      Payout.any_instance.stubs(:should_be_verified_after_time?).returns(false)
      @test_processor.expects(:process_payout).with do |merchant_account, payout_argument|
        payout_argument == @amount
      end
      @test_processor.payout(@payment_transfer.company, {:amount => @amount, :reference => @payment_transfer})
    end
  end

end

