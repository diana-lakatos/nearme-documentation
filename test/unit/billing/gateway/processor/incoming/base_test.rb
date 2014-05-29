require 'test_helper'

class Billing::Gateway::Processor::Incoming::BaseTest < ActiveSupport::TestCase

  class TestProcessor < Billing::Gateway::Processor::Incoming::Base

    attr_accessor :success

    def setup_api_on_initialize
      @gateway = ActiveMerchant::Billing::BogusGateway.new
    end

    def refund_identification(charge_response)
      charge_response["id"]
    end

  end

  SUCCESS_RESPONSE = {"paid_amount"=>"10.00"}
  FAILURE_RESPONSE = {"paid_amount"=>"10.00", "error"=>"Bogus Gateway: Forced failure"}

  setup do
    @user = FactoryGirl.create(:user)
    @test_processor = TestProcessor.new(@user, FactoryGirl.create(:instance), 'USD')
    @gateway = @test_processor.setup_api_on_initialize
  end

  context '#authorize' do
    should "authorize when provided right details" do
      response = @gateway.authorize(1000, "1")
      assert response.success?
    end

    should "not authorize when provided the wrong details" do
      response = @gateway.authorize(1000, "2")
      refute response.success?
    end
  end

  context '#charge' do
    setup do
      @rc = FactoryGirl.create(:reservation_charge)
    end

    should 'create charge object' do
      @test_processor.charge(1000, @rc, "53433")
      charge = Charge.last

      assert_equal @user.id, charge.user_id
      assert_equal 10_00, charge.amount
      assert_equal 'USD', charge.currency
      assert_equal @rc, charge.reference
      assert_equal SUCCESS_RESPONSE, charge.response
      assert charge.success?
    end

    should 'fail' do
      @test_processor.charge(1000, @rc, "2")
      charge = Charge.last
      assert_equal FAILURE_RESPONSE, charge.response
      refute charge.success?
    end
  end

  context 'refund' do
    setup do
      @payment_transfer = FactoryGirl.create(:payment_transfer)
      @test_processor = TestProcessor.new(FactoryGirl.create(:user), FactoryGirl.create(:instance), 'JPY')
    end

    should 'create refund object when succeeded' do
      refund = @test_processor.refund(1000, @payment_transfer, { "id" => "3" })
      assert_equal 1000, refund.amount
      assert_equal 'JPY', refund.currency
      assert_equal SUCCESS_RESPONSE, refund.response
      assert_equal @payment_transfer, refund.reference
      assert refund.success?
    end

    should 'create refund object when failed' do
      refund = @test_processor.refund(1000, @payment_transfer, { "id" => "2" })
      assert_equal 1000, refund.amount
      assert_equal 'JPY', refund.currency
      assert_equal FAILURE_RESPONSE, refund.response
      refute refund.success?
    end
  end
end
