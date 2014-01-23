require 'test_helper'

class Billing::Gateway::BalancedProcessorTest < ActiveSupport::TestCase
  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.create(:reservation)
    @instance.update_attribute(:balanced_api_key, 'test_key')
    @billing_gateway = Billing::Gateway.new(@instance, 'USD')
    merchant = mock()
    marketplace = mock()
    marketplace.stubs(:uri).returns('')
    merchant.stubs(:marketplace).returns(marketplace)
    Balanced::Merchant.stubs(:me).returns(merchant)
  end

  context 'ingoing' do

    setup do
      @billing_gateway.ingoing_payment(@user)
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
          @billing_gateway.store_credit_card(credit_card)
          assert_equal 'test-customer', @instance_client.reload.balanced_user_id
          assert_equal 'test-credit-card', @instance_client.reload.balanced_credit_card_id
        end

        should "raise CreditCardError if cannot store credit card" do
          Balanced::Customer.any_instance.expects(:save).returns(@customer)
          @credit_card.expects(:save).raises(balanced_card_error)
          Balanced::Card.expects(:new).with(credit_card.to_balanced_params).returns(@credit_card)
          assert_raise Billing::CreditCardError do
            @billing_gateway.store_credit_card(credit_card)
          end
        end

        should "create instance client to store balanced_user_id for given istance" do
          @instance_client.destroy
          @customer.expects(:add_card).returns({})
          Balanced::Customer.any_instance.expects(:save).returns(@customer)
          @credit_card.expects(:save).returns(@credit_card)
          Balanced::Card.expects(:new).with(credit_card.to_balanced_params).returns(@credit_card)
          assert_difference "InstanceClient.count" do
            @billing_gateway.store_credit_card(credit_card)
          end
          assert_equal 'test-customer', @user.instance_clients.where(:instance_id => @instance.id).first.balanced_user_id, "Balanced instance_client should have correct blanced_user_id"
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
            @billing_gateway.store_credit_card(credit_card)
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
            @billing_gateway.store_credit_card(credit_card)
          end
          # .reload won't work - https://github.com/attr-encrypted/attr_encrypted/issues/68
          @instance_client = InstanceClient.first
          assert_equal 'new-test-customer', @instance_client.balanced_user_id, "Balanced instance_client should have been updated but wasn't"
          assert_equal 'new-test-credit-card', @instance_client.balanced_credit_card_id, "Balanced credit card id should have changed"
        end
      end
    end

  end

  context '#payout' do

    setup do
      @instance.update_attribute(:balanced_api_key, 'apikey123')
      @gateway = Billing::Gateway.new(@instance, 'USD')
      @company = FactoryGirl.create(:company_with_balanced)
      @payment_transfer = FactoryGirl.create(:payment_transfer_unpaid)
      @payment_transfer.update_column(:amount_cents, 1234)
    end

    context 'new customer' do
      setup do
          @customer = mock()
          @customer.stubs(:uri).returns('test-customer-company')
          @credit = mock()
          @customer.stubs(:credit).returns(@credit)
          Balanced::Customer.expects(:new).with(@company.to_balanced_params).returns(stub(:save => @customer))
          Balanced::BankAccount.expects(:new).with(
            :account_number => @company.balanced_account_number, 
            :bank_code => @company.balanced_bank_code, 
            :name => @company.balanced_name,
            :type => 'checking'
          ).returns(stub(:save => {}))
      end

      should "create a Payout record with reference, amount, currency, and success on success" do
        @customer.stubs(:add_bank_account).returns({})
        @credit.expects(:save).returns(stub(:status => 'pending', :to_yaml => 'yaml'))
        @billing_gateway.outgoing_payment(@instance, @company).payout(amount: @payment_transfer.amount, reference: @payment_transfer)
        payout = Payout.last
        assert_equal 1234, payout.amount
        assert_equal 'USD', payout.currency
        assert_equal 'yaml', payout.response
        assert_equal @payment_transfer, payout.reference
        assert payout.success?
      end

      should "create a Payout record with failure on failure" do
        @customer.stubs(:add_bank_account).returns({})
        @credit.expects(:save).returns(stub(:status => 'failed', :to_yaml => 'yaml'))
        @billing_gateway.outgoing_payment(@instance, @company).payout(amount: @payment_transfer.amount, reference: @payment_transfer)
        payout = Payout.last
        refute payout.success?
        assert_equal 'yaml', payout.response
      end

      should 'store balanced_user_id and time of creating bank' do
        @customer.stubs(:add_bank_account).returns({})
        @credit.expects(:save).returns(stub(:status => 'paid', :to_yaml => 'yaml'))

        Timecop.freeze(Time.zone.now) do
          assert_difference 'InstanceClient.count' do
            @billing_gateway.outgoing_payment(@instance, @company).payout(amount: @payment_transfer.amount, reference: @payment_transfer)
          end
          @instance_client = @company.instance_clients.where(:instance_id => @instance.id).first
          assert_equal 'test-customer-company', @instance_client.balanced_user_id
          assert_equal Time.zone.now.to_i, @instance_client.balanced_bank_account_created_at.to_i
        end

      end

    end

    context 'existing customer' do
      setup do
        @instance_client = FactoryGirl.create(:instance_client, :client => @company, :balanced_user_id => 'test-customer', :balanced_bank_account_created_at => Time.zone.now)
        @customer = mock()
        @credit = mock()
        @credit.expects(:save).returns(stub(:status => 'pending', :to_yaml => 'yaml'))
        @customer.stubs(:credit).returns(@credit)
        Balanced::Customer.expects(:find).with('test-customer').returns(@customer).at_least(1)
      end

      should 'not invalidate old bank account if receiver has not changed balanced details' do
        Billing::Gateway::BalancedProcessor.any_instance.expects(:update_bank_account).never
        @billing_gateway.outgoing_payment(@instance, @company).payout(amount: @payment_transfer.amount, reference: @payment_transfer)
        assert_equal true, Payout.last.success
      end

      should 'try to invalidate old bank account if receiver has changed balanced details' do
        @company.touch(:balanced_account_details_changed_at)
        Billing::Gateway::BalancedProcessor.any_instance.expects(:update_bank_account).once.returns(true)
        @billing_gateway.outgoing_payment(@instance, @company).payout(amount: @payment_transfer.amount, reference: @payment_transfer)
        assert_equal true, Payout.last.success
      end

      should 'update date of creating bank account if old one had to be invalidated' do
        Balanced::BankAccount.expects(:new).returns(stub(:save => {}))
        @company.touch(:balanced_account_details_changed_at)
        @bank_account = stub()
        @bank_account.stubs(:is_valid).returns(false)
        @bank_account.expects(:invalidate).returns(true)
        @customer.stubs(:bank_accounts).returns(stub(:last => @bank_account))
        @customer.stubs(:add_bank_account).returns({})
        Timecop.freeze(Time.zone.now) do
          assert_no_difference 'InstanceClient.count' do
            @billing_gateway.outgoing_payment(@instance, @company).payout(amount: @payment_transfer.amount, reference: @payment_transfer)
          end
          assert_equal Time.zone.now.to_i, InstanceClient.first.balanced_bank_account_created_at.to_i
        end
      end

      should 'raise exception if something goes wrong with invalidation' do
        @company.touch(:balanced_account_details_changed_at)
        @bank_account = stub()
        @bank_account.stubs(:is_valid).returns(true)
        @bank_account.expects(:invalidate).returns(true)
        @customer.stubs(:bank_accounts).returns(stub(:last => @bank_account))
        @credit.unstub(:save)
        assert_raise RuntimeError do |e|
          @billing_gateway.outgoing_payment(@instance, @company).payout(amount: @payment_transfer.amount, reference: @payment_transfer)
          assert e.message.include?('should have been invalidated')
        end
      end

    end

  end

  context 'is_supported?' do

    should 'have balanced_api_key if sender to be supported' do
      sender = stub(:balanced_api_key => '123', :balanced_account_number => '', :balanced_bank_code => '', :balanced_name => '')
      assert Billing::Gateway::BalancedProcessor.is_supported_by?(sender, 'sender')
      refute Billing::Gateway::BalancedProcessor.is_supported_by?(sender, 'receiver')
    end

    should 'have account details if receiver to be supported' do
      receiver = stub(:balanced_account_number => '123', :balanced_bank_code => '321', :balanced_name => 'John Doe', :balanced_api_key => '')
      assert Billing::Gateway::BalancedProcessor.is_supported_by?(receiver, 'receiver')
      refute Billing::Gateway::BalancedProcessor.is_supported_by?(receiver, 'sender')
    end

    context 'all details as receiver to be supported' do
      should 'account_number' do
        receiver = stub(:balanced_account_number => '', :balanced_bank_code => '321', :balanced_name => 'John Doe')
        refute Billing::Gateway::BalancedProcessor.is_supported_by?(receiver, 'receiver')
      end

      should 'bank_code' do
        receiver = stub(:balanced_account_number => '123', :balanced_bank_code => '', :balanced_name => 'John Doe')
        refute Billing::Gateway::BalancedProcessor.is_supported_by?(receiver, 'receiver')
      end

      should 'name' do
        receiver = stub(:balanced_account_number => '123', :balanced_bank_code => '321', :balanced_name => '')
        refute Billing::Gateway::BalancedProcessor.is_supported_by?(receiver, 'receiver')
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

