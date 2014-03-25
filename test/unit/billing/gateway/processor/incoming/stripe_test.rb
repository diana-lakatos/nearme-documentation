require 'test_helper'

class Billing::Gateway::Processor::Incoming::StripeTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
    @instance.update_attribute(:stripe_api_key, "abcd")
    @stripe_processor = Billing::Gateway::Processor::Incoming::Stripe.new(@user, @instance, 'USD')
  end

  context "#charge" do

    setup do
      @instance_client = FactoryGirl.create(:instance_client, :client => @user, :stripe_id => '123')
    end

    should "trigger a charge on the user's credit card" do
      Stripe::Charge.expects(:create).with({:amount => 100_00, :currency => 'USD', :customer => '123'}, @instance.stripe_api_key).returns({})
      @stripe_processor.expects(:charge_successful)
      @stripe_processor.process_charge(100_00)
    end

    should "run the right callback on success" do
      Stripe::Charge.expects(:create).returns({})
      @stripe_processor.expects(:charge_successful)
      assert_no_difference 'InstanceClient.count' do
        @stripe_processor.process_charge(100_00)
      end
    end

    should "run the right callback on failure" do
      Stripe::Charge.expects(:create).raises(stripe_card_error)
      @stripe_processor.expects(:charge_failed)
      begin
        @stripe_processor.process_charge(100_00)
      rescue
      end
    end

    should "raise CardError on card failure" do
      Stripe::Charge.expects(:create).raises(stripe_card_error)
      @stripe_processor.expects(:charge_failed)
      assert_raises Billing::CreditCardError do
        @stripe_processor.process_charge(:amount => 100_00)
      end
    end
  end

  context "#refund" do

    setup do
      @instance_client = FactoryGirl.create(:instance_client, :client => @user, :stripe_id => '123')
      @charge = FactoryGirl.create(:charge_with_stripe_response)
    end

    should "trigger a refund" do
      Stripe::Charge.expects(:retrieve).with('ch_103NzV2NyQr8dJTt7gs44Xnl', @instance.stripe_api_key).returns(stub(:refund => {}))
      @stripe_processor.expects(:refund_successful)
      @stripe_processor.process_refund(100_00, @charge.response)
    end

    should "run the right callback on success" do
      Stripe::Charge.expects(:retrieve).raises(Stripe::StripeError.new('not refunded'))
      @stripe_processor.expects(:refund_failed)
      @stripe_processor.process_refund(100_00, @charge.response)
    end

  end

  context "store_card" do
    context "new customer" do

      should "create a customer record with the card and assign to User" do
        Stripe::Customer.expects(:create).with({:card => stripe_card_details, :email => @user.email}, @instance.stripe_api_key).returns(stub(
          id: '456'
        ))
        assert_difference 'InstanceClient.count' do
          @stripe_processor.store_credit_card(credit_card)
        end
        assert_equal '456', @user.instance_clients.first.stripe_id
      end

      should "raise InvalidRequestError if invalid details" do
        Stripe::Customer.expects(:create).with({:card => stripe_card_details, :email => @user.email}, @instance.stripe_api_key).raises(stripe_invalid_request_error)
        assert_raises Billing::InvalidRequestError do
          @stripe_processor.store_credit_card(credit_card)
        end
      end
    end

    context "existing customer" do
      setup do
        @instance_client = FactoryGirl.create(:instance_client, :client => @user, :stripe_id => '123')
        @stripe_id_was = @instance_client.stripe_id = '123'
        @stripe_customer_mock = mock()
        Stripe::Customer.expects(:retrieve).returns(@stripe_customer_mock)
        @stripe_customer_mock.expects(:card=).with(stripe_card_details)
      end

      should "update an existing assigned Customer record" do
        @stripe_customer_mock.expects(:save)
        @stripe_processor.store_credit_card(credit_card)
        @instance_client = InstanceClient.first
        assert_equal @stripe_id_was, @instance_client.stripe_id,  'Stripe customer id should not have changed'
      end

      should "raise InvalidRequestError if invalid details" do
        @stripe_customer_mock.expects(:save).raises(stripe_invalid_request_error)

        assert_raises Billing::InvalidRequestError do
          @stripe_processor.store_credit_card(credit_card)
        end
      end

      should "set up as new customer if customer not found" do
        @stripe_customer_mock.expects(:save).raises(stripe_customer_not_found_error)
        Stripe::Customer.expects(:create).with({:card => stripe_card_details, :email => @user.email}, @instance.stripe_api_key).returns(stub(
          id: '456'
        ))
        @stripe_processor.store_credit_card(credit_card)
        @instance_client = InstanceClient.first
        assert_equal '456', @instance_client.stripe_id, "Stripe customer id should have changed"
      end
    end
  end

  protected

  # Return an exception that will be caught as a Stripe::CardError
  def stripe_card_error
    Stripe::CardError.new(nil, nil, nil)
  end

  def stripe_invalid_request_error(param = nil)
    Stripe::InvalidRequestError.new(nil, param)
  end

  def stripe_customer_not_found_error
    stripe_invalid_request_error('id')
  end

  def credit_card
    Billing::CreditCard.new(
      number: "1444444444444444",
      expiry_month: '12',
      expiry_year: '2018',
      cvc: '123'
    )
  end

  def stripe_card_details(credit_card = self.credit_card)
    credit_card.to_stripe_params
  end
end
