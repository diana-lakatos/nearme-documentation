require 'test_helper'

class Billing::Gateway::StripeProcessorTest < ActiveSupport::TestCase
  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.create(:reservation)
    @instance.update_attribute(:stripe_api_key, "abcd")
    @billing_gateway = Billing::Gateway.new(@instance).ingoing_payment(@user, 'USD')
  end

  context "#charge" do
    should "trigger a charge on the user's credit card" do
      Stripe::Charge.expects(:create).with({:amount => 100_00, :currency => 'USD', :customer => @user.stripe_id}, @instance.stripe_api_key).returns({})
      @billing_gateway.charge(:amount => 100_00)
    end

    should "create a Charge record with reference, user, amount, currency, and success on success" do
      Stripe::Charge.expects(:create).returns({})
      @billing_gateway.charge(:amount => 100_00, :reference => @reservation)

      charge = Charge.last
      assert_equal @user.id, charge.user_id
      assert_equal 100_00, charge.amount
      assert_equal 'USD', charge.currency
      assert_equal @reservation, charge.reference
      assert charge.success?
    end

    should "create a Charge record with failure on failure" do
      Stripe::Charge.expects(:create).raises(stripe_card_error)

      begin
        @billing_gateway.charge(:amount => 100_00)
      rescue
      end

      charge = Charge.last
      assert !charge.success?
    end

    should "raise CardError on card failure" do
      Stripe::Charge.expects(:create).raises(stripe_card_error)

      assert_raises Billing::CreditCardError do
        @billing_gateway.charge(:amount => 100_00)
      end
    end
  end

  context "store_card" do
    context "new customer" do
      setup do
        @user.stripe_id = nil
      end

      should "create a customer record with the card and assign to User" do
        Stripe::Customer.expects(:create).with({:card => stripe_card_details, :email => @user.email}, @instance.stripe_api_key).returns(stub(
          id: '456'
        ))
        @billing_gateway.store_credit_card(credit_card)
        assert_equal '456', @user.stripe_id
      end

      should "raise InvalidRequestError if invalid details" do
        Stripe::Customer.expects(:create).with({:card => stripe_card_details, :email => @user.email}, @instance.stripe_api_key).raises(stripe_invalid_request_error)

        assert_raises Billing::InvalidRequestError do
          @billing_gateway.store_credit_card(credit_card)
        end
      end
    end

    context "existing customer" do
      setup do
        @stripe_id_was = @user.stripe_id = '123'
        @stripe_customer_mock = mock()
        Stripe::Customer.expects(:retrieve).returns(@stripe_customer_mock)
        @stripe_customer_mock.expects(:card=).with(stripe_card_details)
      end

      should "update an existing assigned Customer record" do
        @stripe_customer_mock.expects(:save)
        @billing_gateway.store_credit_card(credit_card)
        assert_equal @stripe_id_was, @user.stripe_id
      end

      should "raise InvalidRequestError if invalid details" do
        @stripe_customer_mock.expects(:save).raises(stripe_invalid_request_error)

        assert_raises Billing::InvalidRequestError do
          @billing_gateway.store_credit_card(credit_card)
        end
      end

      should "set up as new customer if customer not found" do
        @stripe_customer_mock.expects(:save).raises(stripe_customer_not_found_error)
        Stripe::Customer.expects(:create).with({:card => stripe_card_details, :email => @user.email}, @instance.stripe_api_key).returns(stub(
          id: '456'
        ))
        @billing_gateway.store_credit_card(credit_card)
        assert_equal '456', @user.stripe_id, "Stripe customer id should have changed"
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
