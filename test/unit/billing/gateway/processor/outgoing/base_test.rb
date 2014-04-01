require 'test_helper'

class Billing::Gateway::Processor::Outgoing::BaseTest < ActiveSupport::TestCase

  class TestProcessor < Billing::Gateway::Processor::Outgoing::Base

    attr_accessor :success, :pending

    def setup_api_on_initialize
      self.success = true
    end

    def process_payout(amount)
      if self.pending
        payout_pending('pending payout response')
      elsif self.success
        payout_successful('successful payout response')
      else
        payout_failed('failed payout response')
      end
    end

  end

  setup do
    @test_processor = TestProcessor.new(FactoryGirl.create(:company), 'USD')
  end

  context 'payout' do

    setup do
      @payment_transfer = FactoryGirl.create(:payment_transfer_unpaid)
      @test_processor = TestProcessor.new(@payment_transfer.company, 'JPY')
      @amount = Money.new(1234, 'JPY')
    end

    should 'raise custom exception if amount currency is different from the one declared' do
      @amount = Money.new(1234, 'EUR')
      assert_raise Billing::Gateway::Processor::Base::InvalidStateError do
        @test_processor.payout({:amount => @amount, :reference => @payment_transfer})
      end
    end

    should 'create payout object when succeeded' do
      @test_processor.payout({:amount => @amount, :reference => @payment_transfer})
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
      @test_processor.payout({:amount => @amount, :reference => @payment_transfer})
      payout = Payout.last
      assert_equal 1234, payout.amount
      assert_equal 'JPY', payout.currency
      assert payout.pending?
      refute payout.success?
      refute payout.failed?
    end

    should 'create payout object when failed' do
      @test_processor.success = false
      @test_processor.payout({:amount => @amount, :reference => @payment_transfer})
      payout = Payout.last
      assert_equal 1234, payout.amount
      assert_equal 'JPY', payout.currency
      refute payout.success?
      refute payout.pending?
      assert payout.failed?
    end

    should 'be invoked with right arguments' do
      Payout.any_instance.stubs(:should_be_verified_after_time?).returns(false)
      @test_processor.expects(:process_payout).with do |payout_argument| 
        payout_argument == @amount
      end
      @test_processor.payout({:amount => @amount, :reference => @payment_transfer})
    end
  end

end
