require 'test_helper'

class InstanceTest < ActiveSupport::TestCase

  should validate_presence_of(:name)

  setup do
    @instance = Instance.first
  end

  context 'test mode' do
    setup do
      @instance_payment_gateway = FactoryGirl.create(:stripe_instance_payment_gateway)
      @instance.instance_payment_gateways << @instance_payment_gateway
    end

    should 'should use live credentials when off' do
      @instance.test_mode = false
      assert_equal @instance_payment_gateway.live_settings, @instance.instance_payment_gateways.get_settings_for(:stripe, nil, :live)
    end

    should 'use test credentials' do
      @instance.test_mode = true
      assert_equal @instance_payment_gateway.test_settings, @instance.instance_payment_gateways.get_settings_for(:stripe, nil, :test)
    end
  end

  context 'imap' do

    should 'not be considered with imap if it is blank' do
      @instance.update_column(:support_imap_hash, '')
      assert_equal 0, Instance.with_support_imap.count
    end

    should 'not be considered with imap if it is nil' do
      @instance.update_column(:support_imap_hash, nil)
      assert_equal 0, Instance.with_support_imap.count
    end

    should 'not be considered with imap if it is filled' do
      @instance.update_column(:support_imap_hash, "server: 'imap.gmail.com',port: 993")
      assert_equal 1, Instance.with_support_imap.count
    end
  end

end
