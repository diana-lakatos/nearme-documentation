require 'test_helper'

class Billing::Gateway::BalancedProcessorTest < ActiveSupport::TestCase
  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.create(:reservation)
    @instance.update_attribute(:balanced_api_key, 'test_key')
    @billing_gateway = Billing::Gateway.new(@instance)
    merchant = mock()
    marketplace = mock()
    marketplace.stubs(:uri).returns('')
    merchant.stubs(:marketplace).returns(marketplace)
    Balanced::Merchant.stubs(:me).returns(merchant)
  end

  context 'ingoing' do

    setup do
      @billing_gateway.ingoing_payment(@user, 'USD')
    end

    context "#charge" do
      should "create a Charge record with reference, user, amount, currency, and success on success" do
        Balanced::Customer.expects(:find).returns(Balanced::Customer.new)
        Balanced::Customer.any_instance.expects(:debit).returns({})
        @billing_gateway.charge(:amount => 10000, :reference => @reservation)

        charge = Charge.last
        assert_equal @user.id, charge.user_id
        assert_equal 10000, charge.amount
        assert_equal 'USD', charge.currency
        assert_equal @reservation, charge.reference
        assert charge.success?
      end

      should "create a Charge record with failure on failure" do
        Balanced::Customer.expects(:find).returns(Balanced::Customer.new)
        Balanced::Customer.any_instance.expects(:debit).raises(balanced_card_error)
        assert_raise Billing::CreditCardError do 
          @billing_gateway.charge(:amount => 10000)
        end
        charge = Charge.last
        assert !charge.success?
      end
    end

    context "#store_card" do
      context "new customer" do
        setup do
          @user.balanced_user_id = nil
          @user.balanced_credit_card_id = nil
          @credit_card = mock()
          @credit_card.stubs(:uri).returns('test-credit-card')
          @customer = mock()
          @customer.stubs(:uri).returns('test-customer')
        end

        should "create a customer record with the card and assign to User" do
          @customer.expects(:add_card).returns({})
          Balanced::Customer.any_instance.expects(:save).returns(@customer)
          @credit_card.expects(:save).returns(@credit_card)
          Balanced::Card.expects(:new).with(credit_card.to_balanced_params).returns(@credit_card)
          @billing_gateway.store_credit_card(credit_card)
          assert_equal 'test-customer', @user.balanced_user_id
          assert_equal 'test-credit-card', @user.balanced_credit_card_id
        end

        should "raise CreditCardError if cannot store credit card" do
          Balanced::Customer.any_instance.expects(:save).returns(@customer)
          @credit_card.expects(:save).raises(balanced_card_error)
          Balanced::Card.expects(:new).with(credit_card.to_balanced_params).returns(@credit_card)
          assert_raise Billing::CreditCardError do
            @billing_gateway.store_credit_card(credit_card)
          end
        end
      end

      context "existing customer" do
        setup do
          @balanced_user_id_was = @user.balanced_user_id = 'test-customer'
          @credit_card = mock()
          @credit_card.stubs(:uri).returns('new-test-credit-card')
          @customer = mock()
          @customer.stubs(:uri).returns('new-test-customer')
        end

        should "update an existing assigned Customer record and create new CreditCard record" do
          @customer.expects(:add_card).returns({})
          Balanced::Customer.expects(:find).returns(@customer)
          @credit_card.expects(:save).returns(@credit_card)
          Balanced::Card.expects(:new).with(credit_card.to_balanced_params).returns(@credit_card)
          @billing_gateway.store_credit_card(credit_card)
          assert_equal @balanced_user_id_was, @user.balanced_user_id, "Balanced user id id should not have changed"
          assert_equal 'new-test-credit-card', @user.balanced_credit_card_id, "Balanced credit card id should have changed"
        end

        should "set up as new customer if customer not found" do
          Balanced::Customer.expects(:find).raises(Balanced::NotFound.new({}))
          @customer.expects(:add_card).returns({})
          Balanced::Customer.any_instance.expects(:save).returns(@customer)
          @credit_card.expects(:save).returns(@credit_card)
          Balanced::Card.expects(:new).with(credit_card.to_balanced_params).returns(@credit_card)
          @billing_gateway.store_credit_card(credit_card)
          assert_equal 'new-test-customer', @user.balanced_user_id, "Balanced user id should have changed"
        end
      end
    end

  end

  protected

  def balanced_card_error
    Balanced::UnassociatedCardError.new(Balanced::Card.new)
  end

  def credit_card
    Billing::CreditCard.new(
      credit_number: "1444444444444444",
      expiry_month: '12',
      expiry_year: '2018',
      cvc: '123'
    )
  end
end

