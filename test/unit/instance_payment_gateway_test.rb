require 'test_helper'

class InstancePaymentGatewayTest < ActiveSupport::TestCase

  validate_presence_of(:payment_gateway_id)
  validate_presence_of(:test_settings)
  validate_presence_of(:live_settings)

  should have_many(:country_instance_payment_gateways)
  should belong_to(:instance)
  should belong_to(:payment_gateway)

  setup do
    @instance = Instance.default_instance  
  end


  context "callbacks" do
    setup do
      @stripe = FactoryGirl.build(:stripe_instance_payment_gateway)
      @balanced = FactoryGirl.build(:balanced_instance_payment_gateway)
    end
    
    should "respond_to? country" do
      assert @stripe.respond_to?(:country)
    end

    should "set country settings after save" do
      @stripe.country = "US"
      assert_equal @instance.country_instance_payment_gateways.count, 0
      @stripe.save!
      assert_equal @instance.country_instance_payment_gateways.count, 1
      assert_equal @instance.country_instance_payment_gateways.first.country_alpha2_code, "US"
      assert_equal @instance.country_instance_payment_gateways.first.instance_payment_gateway_id, @stripe.id
    end

    should "change gateway preference for country after save" do
      @stripe.country = "US"
      @stripe.save!
      assert_equal @instance.country_instance_payment_gateways.count, 1
      assert_equal @instance.country_instance_payment_gateways.first.country_alpha2_code, "US"
      assert_equal @instance.country_instance_payment_gateways.first.instance_payment_gateway_id, @stripe.id

      @balanced.country = "US"
      @balanced.save
      assert_equal @instance.country_instance_payment_gateways.count, 1
      assert_equal @instance.country_instance_payment_gateways.first.country_alpha2_code, "US"
      assert_equal @instance.country_instance_payment_gateways.first.instance_payment_gateway_id, @balanced.id
    end

    should "set default values for live_settings and test_settings after find" do
      @stripe = FactoryGirl.create(:stripe_instance_payment_gateway)
      @stripe.live_settings = ""
      assert_equal @stripe.live_settings, ""
      @stripe = InstancePaymentGateway.find(@stripe.id)
      assert_equal @stripe.live_settings.class, Hash
      assert @stripe.live_settings.has_key?(:login)
    end
  end

  context "methods" do
    
    setup do
      @stripe = FactoryGirl.create(:stripe_instance_payment_gateway)
      @instance.instance_payment_gateways << @stripe
    end

    should ".get_settings_for" do
      all_settings = @instance.instance_payment_gateways.get_settings_for(:stripe)
      assert_equal all_settings.class, Hash
      assert_equal all_settings, { login: 'sk_test_r0wxkPFASg9e45UIakAhgpru' }

      key_settings = @instance.instance_payment_gateways.get_settings_for(:stripe, :login)
      assert_equal key_settings.class, String
      assert_equal key_settings, "sk_test_r0wxkPFASg9e45UIakAhgpru"

      mode_settings = @instance.instance_payment_gateways.get_settings_for(:stripe, nil, :live)
      assert_equal mode_settings, @instance.instance_payment_gateways.find(@stripe.id).live_settings

      combined_settings = @instance.instance_payment_gateways.get_settings_for(:stripe, :login, :live)
      assert_equal combined_settings, @instance.instance_payment_gateways.find(@stripe.id).live_settings[:login]
    end

    should ".set_settings_for" do
      @instance.instance_payment_gateways.set_settings_for(:stripe, {login: "123"}, :live)
      assert_equal @instance.instance_payment_gateways.get_settings_for(:stripe, :login, :live), "123"
      assert_not_equal @instance.instance_payment_gateways.get_settings_for(:stripe, :login, :test), "123"
    end

  end

end
