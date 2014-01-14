require 'test_helper'

class Billing::CreditCardTest < ActiveSupport::TestCase

  setup do
    @credit_card = credit_card
  end

  context '#to_stripe_params' do

    setup do
      @credit_card_hash = @credit_card.to_stripe_params
    end

    should "return cvc as a string" do
      assert_equal '032', @credit_card_hash[:cvc]
    end

    should "get two last digits as year" do
      assert_equal 18, @credit_card_hash[:exp_year]
    end

    should "ignore spaces in credit card number" do
      assert_equal '1444 4444 4444 4444', @credit_card_hash[:number]
    end
  end

  context '#to_paypal_params' do

    setup do
      @credit_card_hash = @credit_card.to_paypal_params
    end

    should "ignore spaces in credit card number" do
      assert_equal '1444444444444444', @credit_card_hash[:number]
    end

    should "get all four digits as year" do
      assert_equal 2118, @credit_card_hash[:expire_year]
    end

    context 'type' do

      should 'return correct type for visa' do
        assert_equal 'visa', credit_card('4242424242424242').to_paypal_params[:type]
      end

      should 'return correct type for master card' do
        assert_equal 'mastercard', credit_card('5555555555554444').to_paypal_params[:type]
      end

      should 'return correct type for american express' do
        assert_equal 'amex', credit_card('378282246310005').to_paypal_params[:type]
      end

      should 'return correct type for discover' do
        assert_equal 'discover', credit_card('6011111111111117').to_paypal_params[:type]
      end

      should 'return correct type for dinners club' do
        assert_equal 'dinersclub', credit_card('30569309025904').to_paypal_params[:type]
      end

      should 'return correct type for jcb' do
        assert_equal 'jcb', credit_card('3530111333300000').to_paypal_params[:type]
      end
    end
  end

  context '#credit card error' do

    context 'normalize param' do

      should 'convert "expire_month, expire_year" to "exp_month"' do
        @error = Billing::CreditCardError.new('message', 'expire_month, expire_year')
        assert_equal 'exp_month', @error.param
      end

      should 'convert "expire_month" to "exp_month"' do
        @error = Billing::CreditCardError.new('message', 'expire_month')
        assert_equal 'exp_month', @error.param
      end

      should 'convert "expire_year" to "exp_month"' do
        @error = Billing::CreditCardError.new('message', 'expire_year')
        assert_equal 'exp_month', @error.param
      end

      should 'convert "cvv2" to "cvc"' do
        @error = Billing::CreditCardError.new('message', 'cvv2')
        assert_equal 'cvc', @error.param
      end

      should 'convert "type" to "cc"' do
        @error = Billing::CreditCardError.new('message', 'type')
        assert_equal 'cc', @error.param
      end

      should 'return param name by default' do
        @error = Billing::CreditCardError.new('message', 'some_param')
        assert_equal 'some_param', @error.param
      end
    end

  end


  private

  def credit_card(number = '1444 4444 4444 4444')
    Billing::CreditCard.new(
      number: number,
      expiry_month: '12',
      expiry_year: '2118',
      cvc: '032'
    )
  end
end
