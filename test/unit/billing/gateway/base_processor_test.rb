require 'test_helper'

class Billing::Gateway::BaseProcessorTest < ActiveSupport::TestCase


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

      should 'require process_payout' do
        assert_raise RuntimeError do
          @test_processor.process_payout
        end
      end


      should 'require instance_supported?' do
        assert_raise RuntimeError do
          TestProcessor.instance_supported?(nil)
        end
      end

      should 'require currency_supported?' do
        assert_raise RuntimeError do
          TestProcessor.currency_supported?(nil)
        end
      end

      should 'require processor_supported?' do
        assert_raise RuntimeError do
          TestProcessor.processor_supported?(nil)
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
