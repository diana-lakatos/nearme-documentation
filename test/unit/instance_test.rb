require 'test_helper'

class InstanceTest < ActiveSupport::TestCase

  should validate_presence_of(:name)

  setup do
    @instance = Instance.default_instance
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

end
