require 'test_helper'

class Billing::Gateway::OutcomingTest < ActiveSupport::TestCase

  setup do
    @company = FactoryGirl.create(:company, :paypal_email => 'paypal@example.com')
  end

  context 'outgoing_processor' do

    should 'know if there is outgoing processor that can potentially handle payment' do
      assert Billing::Gateway::Outcoming.new(@company, 'USD').possible?
    end

    should 'know if there is no outgoing processor that can potentially handle payment' do
      refute Billing::Gateway::Outcoming.new(@company, 'ABC').possible?
    end

  end

  context '#find_outgoing_processor_class' do

    context 'paypal' do

      should 'accept objects which have paypal email' do
        assert Billing::Gateway::Processor::Outcoming::Paypal === Billing::Gateway::Outcoming.new(@company, 'EUR').processor
      end

      should 'not accept objects with blank paypal_email' do
        @company.expects(:paypal_email).returns('')
        assert_nil Billing::Gateway::Outcoming.new(@company, 'EUR').processor
      end

    end

    context 'balanced' do

      setup do
        @instance = @company.instance
        @instance.update_attribute(:balanced_api_key, 'apikey123')
        @instance.update_attribute(:paypal_username, '')
      end

      should 'accept objects which have balanced api and currency' do
        @company = FactoryGirl.create(:company_with_balanced)
        assert_equal "Balanced", Billing::Gateway::Outcoming.new(@company, 'USD').processor.class.to_s.demodulize
      end

      should 'not accept objects which have balanced api but wrong currency' do
        @company = FactoryGirl.create(:company_with_balanced)
        assert_nil Billing::Gateway::Outcoming.new(@company, 'EUR').processor
      end

      should 'not accept receiver without instance client' do
        @company = FactoryGirl.create(:company)
        assert_nil Billing::Gateway::Outcoming.new(@company, 'USD').processor
      end

      should 'not accept receiver without filled balanced user id' do
        @company = FactoryGirl.create(:company_with_balanced)
        @company.instance_clients.first.update_attribute(:balanced_user_id, '')
        assert_nil Billing::Gateway::Outcoming.new(@company, 'USD').processor
      end

    end

  end

end
