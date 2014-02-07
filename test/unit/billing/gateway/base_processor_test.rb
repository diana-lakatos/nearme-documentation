require 'test_helper'

class Billing::Gateway::BaseProcessorTest < ActiveSupport::TestCase

  class TestProcessor < Billing::Gateway::BaseProcessor

    attr_accessor :success

    def setup_api_on_initialize
      self.success = true
    end

    def process_charge(amount_cents)
      if self.success
        charge_successful('successful charge response')
      else
        charge_failed('failed charge response')
      end
    end

    def process_payout(amount)
      if self.success
        payout_successful('successful payout response')
      else
        payout_failed('failed payout response')
      end
    end

    def process_refund(amount_cents, charge_response)
      if self.success
        refund_successful('successful refund response')
      else
        refund_failed('failed refund response')
      end
    end

  end

  setup do
    @test_processor = TestProcessor.new(FactoryGirl.create(:instance), 'USD')
  end

  context 'charge' do

    setup do
      @rc = FactoryGirl.create(:reservation_charge)
      @user = FactoryGirl.create(:user)
      @test_processor.ingoing_payment(@user)
    end

    should 'create charge object' do
      @test_processor.charge({:amount_cents => 1000, :reference => @rc})
      charge = Charge.last
      assert_equal @user.id, charge.user_id
      assert_equal 10_00, charge.amount
      assert_equal 'USD', charge.currency
      assert_equal @rc, charge.reference
      assert_equal 'successful charge response', YAML.load(charge.response)
      assert charge.success?
    end

    should 'fail' do
      @test_processor.success = false
      @test_processor.charge({:amount_cents => 1000, :reference => @rc})
      charge = Charge.last
      assert_equal 'failed charge response', YAML.load(charge.response)
      refute charge.success?
    end

    should 'be invoked with right arguments' do
      @test_processor.expects(:process_charge).with do |charge_argument| 
        charge_argument == 1000
      end
      @test_processor.charge({:amount_cents => 1000, :reference => @rc})
    end

  end

  context 'payout' do

    setup do
      @payment_transfer = FactoryGirl.create(:payment_transfer_unpaid)
      @test_processor = TestProcessor.new(FactoryGirl.create(:instance), 'JPY').outgoing_payment(@payment_transfer.company.instance, @payment_transfer.company)
      @amount = Money.new(1234, 'JPY')
    end

    should 'raise custom exception if amount currency is different from the one declared' do
      @amount = Money.new(1234, 'EUR')
      assert_raise Billing::Gateway::BaseProcessor::InvalidStateError do
        @test_processor.payout({:amount => @amount, :reference => @payment_transfer})
      end
    end

    should 'create payout object when succeeded' do
      @test_processor.payout({:amount => @amount, :reference => @payment_transfer})
      payout = Payout.last
      assert_equal 1234, payout.amount
      assert_equal 'JPY', payout.currency
      assert_equal 'successful payout response', YAML.load(payout.response)
      assert_equal @payment_transfer, payout.reference
      assert payout.success?
    end

    should 'create payout object when failed' do
      @test_processor.success = false
      @test_processor.payout({:amount => @amount, :reference => @payment_transfer})
      payout = Payout.last
      assert_equal 1234, payout.amount
      assert_equal 'JPY', payout.currency
      assert_equal 'failed payout response', YAML.load(payout.response)
      refute payout.success?
    end

    should 'be invoked with right arguments' do
      @test_processor.expects(:process_payout).with do |payout_argument| 
        payout_argument == @amount
      end
      @test_processor.payout({:amount => @amount, :reference => @payment_transfer})
    end
  end

  context 'refund' do
    setup do
      @payment_transfer = FactoryGirl.create(:payment_transfer)
      @test_processor = TestProcessor.new(FactoryGirl.create(:instance), 'JPY').outgoing_payment(@payment_transfer.company.instance, @payment_transfer.company)
    end

    should 'create refund object when succeeded' do
      refund = @test_processor.refund({:amount_cents => 1234, :reference => @payment_transfer, :charge_response => 'response'})
      assert_equal 1234, refund.amount
      assert_equal 'JPY', refund.currency
      assert_equal 'successful refund response', YAML.load(refund.response)
      assert_equal @payment_transfer, refund.reference
      assert refund.success?
    end

    should 'create refund object when failed' do
      @test_processor.success = false
      refund = @test_processor.refund({:amount_cents => 1234, :reference => @payment_transfer, :charge_response => 'response'})
      assert_equal 1234, refund.amount
      assert_equal 'JPY', refund.currency
      assert_equal 'failed refund response', YAML.load(refund.response)
      refute refund.success?
    end

    should 'be invoked with right arguments' do
      @test_processor.expects(:process_refund).with do |amount, response| 
        amount == 1234 && response == 'response'
      end
      @test_processor.refund({:amount_cents => 1234, :reference => @payment_transfer, :charge_response => 'response'})
    end
  end

end
