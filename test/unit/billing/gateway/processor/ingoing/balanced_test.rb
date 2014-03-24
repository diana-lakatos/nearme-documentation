require 'test_helper'

class Billing::Gateway::Processor::Ingoing::BalancedTest < ActiveSupport::TestCase
  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
    @instance.update_attribute(:balanced_api_key, 'test_key')
    @balanced_processor = Billing::Gateway::Processor::Ingoing::Balanced.new(@user, @instance, 'USD')
    merchant = mock()
    marketplace = mock()
    marketplace.stubs(:uri).returns('')
    merchant.stubs(:marketplace).returns(marketplace)
    Balanced::Merchant.stubs(:me).returns(merchant)
  end

  context "#charge" do
    should "create a Charge record with reference, user, amount, currency, and success on success" do
      Balanced::Customer.expects(:find).returns(Balanced::Customer.new)
      Balanced::Customer.any_instance.expects(:debit).returns({})
      @balanced_processor.expects(:charge_successful)
      @balanced_processor.process_charge(10000)
    end

    should 'charge the right amount' do
      InstanceClient.any_instance.stubs(:balanced_user_id).returns('balanced-test-id')
      InstanceClient.any_instance.stubs(:balanced_credit_card_id).returns('balanced-credit-card')
      Balanced::Customer.expects(:find).with('balanced-test-id').returns(Balanced::Customer.new)
      Balanced::Customer.any_instance.expects(:debit).with do |debit_hash|
        debit_hash[:amount] == 12345 && debit_hash[:source_uri] == 'balanced-credit-card'
      end.returns({})
      @balanced_processor.expects(:charge_successful)
      @balanced_processor.process_charge(12345)
    end

    should "create a Charge record with failure on failure" do
      Balanced::Customer.expects(:find).returns(Balanced::Customer.new)
      Balanced::Customer.any_instance.expects(:debit).raises(balanced_card_error)
      @balanced_processor.expects(:charge_failed)
      assert_raise Billing::CreditCardError do 
        @balanced_processor.process_charge(10000)
      end
    end
  end

  context "#refund" do

    setup do
      @debit = stub()
      YAML.expects(:load).with('response').returns(@debit)
    end

    should "run the right callback on success" do
      @debit.expects(:refund).returns(true)
      @balanced_processor.expects(:refund_successful)
      @balanced_processor.process_refund(100_00, 'response')
    end

    should "run the right callback on failure" do
      @debit.expects(:refund).raises(StandardError.new('not refunded'))
      @balanced_processor.expects(:refund_failed)
      @balanced_processor.process_refund(100_00, 'response')
    end

  end

  context "#store_card" do
    context "new customer" do
      setup do
        @instance_client = FactoryGirl.create(:instance_client, :client => @user)
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
        @balanced_processor.store_credit_card(credit_card)
        assert_equal 'test-customer', @instance_client.reload.balanced_user_id
        assert_equal 'test-credit-card', @instance_client.reload.balanced_credit_card_id
      end

      should "raise CreditCardError if cannot store credit card" do
        Balanced::Customer.any_instance.expects(:save).returns(@customer)
        @credit_card.expects(:save).raises(balanced_card_error)
        Balanced::Card.expects(:new).with(credit_card.to_balanced_params).returns(@credit_card)
        assert_raise Billing::CreditCardError do
          @balanced_processor.store_credit_card(credit_card)
        end
      end

      should "create instance client to store balanced_user_id for given istance" do
        @instance_client.destroy
        @customer.expects(:add_card).returns({})
        Balanced::Customer.any_instance.expects(:save).returns(@customer)
        @credit_card.expects(:save).returns(@credit_card)
        Balanced::Card.expects(:new).with(credit_card.to_balanced_params).returns(@credit_card)
        assert_difference "InstanceClient.count" do
          @balanced_processor.store_credit_card(credit_card)
        end
        assert_equal 'test-customer', @user.instance_clients.first.balanced_user_id, "Balanced instance_client should have correct blanced_user_id"
      end
    end

    context "existing customer" do
      setup do
        @instance_client = FactoryGirl.create(:instance_client, :client => @user, :balanced_user_id => 'test-customer', :balanced_credit_card_id => 'test-credit-card')
        @balanced_user_id_was = @instance_client.balanced_user_id
        @credit_card = mock()
        @credit_card.stubs(:uri).returns('new-test-credit-card')
        @customer = mock()
        @customer.stubs(:uri).returns('new-test-customer')
      end

      should "update an existing assigned Customer record and create new CreditCard record" do
        Balanced::Customer.expects(:find).returns(@customer)
        @customer.expects(:add_card).returns({})
        @credit_card.expects(:save).returns(@credit_card)
        Balanced::Card.expects(:new).with(credit_card.to_balanced_params).returns(@credit_card)
        assert_no_difference "InstanceClient.count" do
          @balanced_processor.store_credit_card(credit_card)
        end
        # .reload won't work - https://github.com/attr-encrypted/attr_encrypted/issues/68
        @instance_client = InstanceClient.first
        assert_equal @balanced_user_id_was, @instance_client.balanced_user_id, "Balanced user id id should not have changed"
        assert_equal 'new-test-credit-card', @instance_client.balanced_credit_card_id, "Balanced credit card id should have changed"
      end

      should "update existing instance_client to store new balanced_user_id if it was invalid" do
        Balanced::Customer.expects(:find).with('test-customer').raises(Balanced::NotFound.new({}))
        @customer.expects(:add_card).returns({})
        Balanced::Customer.any_instance.expects(:save).returns(@customer)
        @credit_card.expects(:save).returns(@credit_card)
        Balanced::Card.expects(:new).with(credit_card.to_balanced_params).returns(@credit_card)
        assert_no_difference 'InstanceClient.count' do
          @balanced_processor.store_credit_card(credit_card)
        end
        # .reload won't work - https://github.com/attr-encrypted/attr_encrypted/issues/68
        @instance_client = InstanceClient.first
        assert_equal 'new-test-customer', @instance_client.balanced_user_id, "Balanced instance_client should have been updated but wasn't"
        assert_equal 'new-test-credit-card', @instance_client.balanced_credit_card_id, "Balanced credit card id should have changed"
      end
    end
  end

  context 'is_supported?' do

    should 'be supported if instance_client with the right instance exists and has balanced_user_id' do
      @company = FactoryGirl.create(:company)
      FactoryGirl.create(:instance_client, :client => @company, :instance => @company.instance, :balanced_user_id => 'present')
      assert Billing::Gateway::Processor::Ingoing::Balanced.is_supported_by?(@company)
    end

    should 'not be supported if instance_client exists but for other instance' do
      @company = FactoryGirl.create(:company)
      FactoryGirl.create(:instance_client, :client => @company, :balanced_user_id => 'present').update_column(:instance_id, FactoryGirl.create(:instance).id)
      refute Billing::Gateway::Processor::Ingoing::Balanced.is_supported_by?(@company)
    end

    should 'not be supported if instance_client with the right instance exists but without balanced_user_id' do
      @company = FactoryGirl.create(:company)
      FactoryGirl.create(:instance_client, :client => @company, :instance => @company.instance)
      refute Billing::Gateway::Processor::Ingoing::Balanced.is_supported_by?(@company)
    end

    should 'not be supported if instance_client does not exist' do
      @company = FactoryGirl.create(:company)
      refute Billing::Gateway::Processor::Ingoing::Balanced.is_supported_by?(@company)
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

