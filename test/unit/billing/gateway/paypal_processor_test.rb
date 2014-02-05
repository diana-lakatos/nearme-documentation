require 'test_helper'

class Billing::Gateway::PaypalProcessorTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @paypal_processor = Billing::Gateway::PaypalProcessor.new(@instance, 'EUR')
  end

  context 'ingoing' do

    setup do
      @user = FactoryGirl.create(:user)
      @paypal_processor.ingoing_payment(@user)
      PayPal::SDK::REST::Payment.any_instance.stubs(:error).returns([]).at_least(0)
      PayPal::SDK::REST::CreditCard.any_instance.stubs(:error).returns([]).at_least(0)
    end

    context "#charge" do

      setup do
        @instance_client = FactoryGirl.create(:instance_client, :client => @user, :paypal_id => 'CARD-ABC123')
      end

      should "invoke right callback on success" do
        PayPal::SDK::REST::Payment.expects(:new).returns(stub(:create => true))
        @paypal_processor.expects(:charge_successful)
        @paypal_processor.process_charge(1000)
      end

      should "invoke right callback on failure" do
        PayPal::SDK::REST::Payment.expects(:new).returns(stub(:create => false, :error => {}))
        @paypal_processor.expects(:charge_failed)
        assert_raise Billing::CreditCardError do
          @paypal_processor.process_charge(1000)
        end
      end

      should "charge with right arguments" do
        PayPal::SDK::REST::Payment.expects(:new).with(payment_arguments).once.returns(stub(:create => true))
        @paypal_processor.expects(:charge_successful)
        @paypal_processor.process_charge(1000)
      end

    end

    context "#refund" do

      setup do
        @paypal_processor.ingoing_payment(@user)
        @sale = stub()
        @sale.expects(:present?).returns(true)
        @payment = stub(:transactions => [stub(:related_resources => [stub(:sale => @sale)])])
        @response = stub()
        @sale.expects(:refund).returns(@response)
        YAML.expects(:load).with('response').returns(@payment)
      end

      should "run the right callback on success" do
        @response.expects(:success?).returns(true)
        @paypal_processor.expects(:refund_successful).with(@response)
        @paypal_processor.process_refund(100_00, 'response')
      end

      should "run the right callback on failure" do
        @response.expects(:success?).returns(false)
        @response.expects(:error).returns(stub(:inspect => { :error => 'hash' }))
        @paypal_processor.expects(:refund_failed).with({:error => 'hash'})
        @paypal_processor.process_refund(100_00, 'response')
      end

    end

    context "#store_card" do
      context "new customer" do
        setup do
          @instance_client = FactoryGirl.create(:instance_client, :client => @user)
          @credit_card = mock()
          @credit_card.stubs(:id).returns('CARD-ABC123')
        end

        should "create a customer record with the card and assign to User" do
          @credit_card.expects(:create).returns(true)
          PayPal::SDK::REST::CreditCard.expects(:new).with(credit_card_arguments).returns(@credit_card)
          @paypal_processor.store_credit_card(credit_card)
          @instance_client = InstanceClient.first
          assert_equal 'CARD-ABC123', @instance_client.paypal_id
        end

        should "raise CreditCardError if cannot store credit card" do
          @credit_card.expects(:create).returns(false)
          @credit_card.stubs(:error).returns({})
          PayPal::SDK::REST::CreditCard.expects(:new).with(credit_card_arguments).returns(@credit_card)
          assert_raise Billing::CreditCardError do
            @paypal_processor.store_credit_card(credit_card)
          end
        end
      end

      context "existing customer" do
        setup do
          @instance_client = FactoryGirl.create(:instance_client, :client => @user, :paypal_id => '123')
          @paypal_id_was = @instance_client.paypal_id
          @credit_card = mock()
          @credit_card.stubs(:id).returns('CARD-ABC123')
          @credit_card.stubs(:error).returns([]).at_least(0)
        end

        should "update an existing assigned Customer record" do
          PayPal::SDK::REST::CreditCard.expects(:find).returns(@credit_card)
          @paypal_processor.store_credit_card(credit_card)
          @instance_client = InstanceClient.first
          assert_equal '123', @instance_client.paypal_id, "Paypal id should not have changed"
        end

        should "set up as new customer if customer not found" do
          @credit_card.stubs(:create).returns(true)
          PayPal::SDK::REST::CreditCard.expects(:find).raises(PayPal::SDK::Core::Exceptions::ResourceNotFound.new({}))
          PayPal::SDK::REST::CreditCard.expects(:new).with(credit_card_arguments).returns(@credit_card)
          @paypal_processor.store_credit_card(credit_card)
          @instance_client = InstanceClient.first
          assert_equal @credit_card.id, @instance_client.paypal_id, "Paypal id should have changed"
        end
      end
    end

  end

  context 'outgoing' do

    context '#payout' do

      setup do
        @company = FactoryGirl.create(:company)
        @company.update_attribute(:paypal_email, 'receiver@example.com')
        @company.instance.update_attribute(:paypal_email, 'sender@example.com')
      end

      should "create a Payout record with reference, amount, currency, and success on success" do
        api_mock = mock()
        api_mock.expects(:build_pay)
        pay_response_mock = mock()
        pay_response_mock.stubs(:success? => true, :to_yaml => 'yaml')
        api_mock.expects(:pay).returns(pay_response_mock)
        PayPal::SDK::AdaptivePayments::API.expects(:new).returns(api_mock)
        @paypal_processor = Billing::Gateway::PaypalProcessor.new(@instance, 'EUR').outgoing_payment(@company.instance, @company)
        @paypal_processor.expects(:payout_successful)
        @paypal_processor.process_payout(Money.new(1000, 'EUR'))
      end

      should "create a Payout record with failure on failure" do
        api_mock = mock()
        api_mock.expects(:build_pay)
        pay_response_mock = mock()
        error_mock = mock()
        error_mock.stubs(:to_yaml => 'yaml')
        pay_response_mock.stubs(:success?).returns(false)
        pay_response_mock.stubs(:error).returns(error_mock)
        api_mock.expects(:pay).returns(pay_response_mock)
        PayPal::SDK::AdaptivePayments::API.expects(:new).returns(api_mock)
        @paypal_processor = Billing::Gateway::PaypalProcessor.new(@instance, 'EUR').outgoing_payment(@company.instance, @company)
        @paypal_processor.expects(:payout_failed)
        @paypal_processor.process_payout(Money.new(1000, 'EUR'))
      end

      should 'build pay object with right arguments' do
        api_mock = mock()
        api_mock.expects(:build_pay).with({
          :actionType => "PAY",
          :currencyCode => 'EUR',
          :feesPayer => "SENDER",
          :cancelUrl => "http://example.com",
          :returnUrl => "http://example.com",
          :receiverList => {
            :receiver => [{
              :amount => '12.34',
              :email => 'receiver@example.com' 
            }] 
          },
          :senderEmail => 'sender@example.com'
        })
        PayPal::SDK::AdaptivePayments::API.expects(:new).returns(api_mock)
        pay_response_mock = mock()
        pay_response_mock.stubs(:success? => true, :to_yaml => 'yaml')
        api_mock.expects(:pay).returns(pay_response_mock)
        @paypal_processor = Billing::Gateway::PaypalProcessor.new(@instance, 'EUR').outgoing_payment(@company.instance, @company)
        @paypal_processor.expects(:payout_successful)
        @paypal_processor.process_payout(Money.new(1234, 'EUR'))
      end

    end

  end

  protected

  def payment_arguments
    {
      :intent => "sale",
      # Payer
      # A resource representing a Payer that funds a payment
      # Use the List of `FundingInstrument` and the Payment Method
      # as 'credit_card'
      :payer => {
        :payment_method => "credit_card",

        # FundingInstrument
        # A resource representing a Payeer's funding instrument.
        # In this case, a Saved Credit Card can be passed to
        # charge the payment.
        :funding_instruments => [{
          # CreditCardToken
          # A resource representing a credit card that can be
          # used to fund a payment.
          :credit_card_token => {
            :credit_card_id => @instance_client.paypal_id,
            :payer_id => @user.id }}]
      },

      # Transaction
      # A transaction defines the contract of a
      # payment - what is the payment for and who
      # is fulfilling it
      :transactions => [{

        # Item List
        :item_list => {
          :items => [{
            :name => "Reservation",
            :price => '10.00',
            :currency => 'EUR',
            :quantity => 1 }]
        },

        # Amount
        # Let's you specify a payment amount.
        :amount => {
          :total => '10.00',
          :currency => 'EUR' },
      }]
    }
  end

  def credit_card
    Billing::CreditCard.new(
      number: "4242 4242 4242 4242",
      expiry_month: '12',
      expiry_year: '2018',
      cvc: '123'
    )
  end

  def credit_card_arguments
    {
      :number => "4242424242424242",
      :expire_month => 12,
      :expire_year => 2018,
      :type => 'visa',
      :cvv2 => '123',
      :payer_id => @user.id,
      :first_name => @user.first_name, 
      :last_name => @user.last_name
    }
  end
end
