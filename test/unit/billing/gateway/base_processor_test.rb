require 'test_helper'

class Billing::Gateway::BaseProcessorTest < ActiveSupport::TestCase

  context '#find_ingoing_processor_class' do

    context 'stripe' do

      should 'accept USD' do
        assert_equal Billing::Gateway::StripeProcessor, Billing::Gateway::BaseProcessor.find_ingoing_processor_class('USD')
      end

    end

    context 'paypal' do
      should 'accept GBP' do
        assert_equal Billing::Gateway::PaypalProcessor, Billing::Gateway::BaseProcessor.find_ingoing_processor_class('GBP')
      end

      should 'accept JPY' do
        assert_equal Billing::Gateway::PaypalProcessor, Billing::Gateway::BaseProcessor.find_ingoing_processor_class('JPY')
      end

      should 'accept EUR' do
        assert_equal Billing::Gateway::PaypalProcessor, Billing::Gateway::BaseProcessor.find_ingoing_processor_class('EUR')
      end

      should 'accept CAD' do
        assert_equal Billing::Gateway::PaypalProcessor, Billing::Gateway::BaseProcessor.find_ingoing_processor_class('CAD')
      end
    end

    should 'return nil if currency is not supported by any processor' do
      assert_nil Billing::Gateway::BaseProcessor.find_ingoing_processor_class('ABC')
    end
  end


  context '#find_outgoing_processor_class' do

    context 'paypal' do

      should 'accept objects which have paypal email' do
        @mock = mock()
        @mock.expects(:paypal_email).returns('paypal@example.com').twice
        assert_equal Billing::Gateway::PaypalProcessor, Billing::Gateway::BaseProcessor.find_outgoing_processor_class(@mock, @mock)
      end

      should 'not accept objects with blank paypal_email' do
        @mock = mock()
        @mock.expects(:paypal_email).returns('')
        assert_equal nil, Billing::Gateway::BaseProcessor.find_outgoing_processor_class(@mock, @mock)
      end

      should 'not accept objects without paypal_email' do
        @mock = mock()
        assert_equal nil, Billing::Gateway::BaseProcessor.find_outgoing_processor_class(@mock, @mock)
      end

    end

  end

  context 'sample class that inherits' do
    class TestProcessor < Billing::Gateway::BaseProcessor
    end

    context 'required methods' do

      setup do
        @test_processor = TestProcessor.new(FactoryGirl.create(:instance))
      end

      should 'require process_charge' do
        assert_raise RuntimeError do
          @test_processor.process_charge
        end
      end

      should 'require ingoing_payment_supported?' do
        assert_raise RuntimeError do
          @test_processor.ingoing_payment_supported?(nil)
        end
      end

      should 'require outgoing_payment_supported?' do
        assert_raise RuntimeError do
          @test_processor.outgoing_payment_supported?(nil, nil)
        end
      end

      should 'require store_credit_card' do
        assert_raise RuntimeError do
          @test_processor.store_credit_card(mock())
        end
      end
    end
  end

end
