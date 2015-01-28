require 'test_helper'

class Billing::Gateway::Processor::Incoming::BaseTest < ActiveSupport::TestCase

  class TestProcessor < Billing::Gateway::Processor::Incoming::Base

    attr_accessor :success

    def setup_api_on_initialize
      @gateway = ActiveMerchant::Billing::BogusGateway.new
    end

    def refund_identification(charge)
      charge.response.params["id"]
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
      @rc = FactoryGirl.create(:payment)
    end

    should 'create charge object' do
      @test_processor.charge(1000, @rc, "53433")
      charge = Charge.last

      assert_equal @user.id, charge.user_id
      assert_equal 10_00, charge.amount
      assert_equal 'USD', charge.currency
      assert_equal @rc, charge.payment
      assert_equal SUCCESS_RESPONSE, charge.response.params
      assert charge.success?
    end

    should 'fail' do
      @test_processor.charge(1000, @rc, "2")
      charge = Charge.last
      assert_equal FAILURE_RESPONSE, charge.response.params
      refute charge.success?
    end
  end

  context 'refund' do
    setup do
      @payment_transfer = FactoryGirl.create(:payment_transfer)
      @charge = FactoryGirl.create(:charge)
      @payment = @charge.payment
      @test_processor = TestProcessor.new(FactoryGirl.create(:user), FactoryGirl.create(:instance), 'JPY')
    end

    should 'create refund object when succeeded' do
      charge_params = { "id" => "3" }
      charge_response = ActiveMerchant::Billing::Response.new true, 'OK', charge_params
      @charge.update_attribute(:response, charge_response)
      refund = @test_processor.refund(1000, @payment, @charge)
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
      refund = @test_processor.refund(1000, @payment, @charge)
      assert_equal 1000, refund.amount
      assert_equal 'JPY', refund.currency
      assert_equal FAILURE_RESPONSE, refund.response.params
      refute refund.success?
    end
  end
end
