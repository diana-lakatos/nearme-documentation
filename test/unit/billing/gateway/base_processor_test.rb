require 'test_helper'

class Billing::Gateway::BaseProcessorTest < ActiveSupport::TestCase

  context '#find_processor_class' do

    context 'stripe' do

      should 'accept USD' do
        assert_equal Billing::Gateway::StripeProcessor, Billing::Gateway::BaseProcessor.find_processor_class('USD')
      end

    end

    context 'paypal' do
      should 'accept GBP' do
        assert_equal Billing::Gateway::PaypalProcessor, Billing::Gateway::BaseProcessor.find_processor_class('GBP')
      end

      should 'accept JPY' do
        assert_equal Billing::Gateway::PaypalProcessor, Billing::Gateway::BaseProcessor.find_processor_class('JPY')
      end

      should 'accept EUR' do
        assert_equal Billing::Gateway::PaypalProcessor, Billing::Gateway::BaseProcessor.find_processor_class('EUR')
      end

      should 'accept CAD' do
        assert_equal Billing::Gateway::PaypalProcessor, Billing::Gateway::BaseProcessor.find_processor_class('CAD')
      end
    end

    should 'return nil if currency is not supported by any processor' do
      assert_nil Billing::Gateway::BaseProcessor.find_processor_class('ABC')
    end
  end

  context 'sample class that inherits' do
    class TestProcessor < Billing::Gateway::BaseProcessor
    end

    context 'self.payment_supported?' do

      should 'raise exception if supported_currencies is not defined' do

        assert_raise RuntimeError do
          TestProcessor.payment_supported?('USD')
        end
      end

      context 'defined constant' do

        class TestProcessorWithConstant < Billing::Gateway::BaseProcessor
          SUPPORTED_CURRENCIES = ['XYZ']
        end

        should 'returns false if does not support given currency ' do
          refute TestProcessorWithConstant.payment_supported?('ABC')
        end

        should 'returns true if supports given currency ' do
          assert TestProcessorWithConstant.payment_supported?('XYZ')
        end

      end
    end

    context 'required methods' do

      setup do
        @test_processor = TestProcessor.new(User.first, 'USD', FactoryGirl.create(:instance))
      end

      should 'require process_charge' do
        assert_raise RuntimeError do
          @test_processor.process_charge
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
