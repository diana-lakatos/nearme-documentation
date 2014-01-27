require 'test_helper'

class Billing::Gateway::BalancedProcessorTest < ActiveSupport::TestCase
  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.create(:reservation)
    @instance.update_attribute(:balanced_api_key, 'test_key')
    @balanced_processor = Billing::Gateway::BalancedProcessor.new(@instance, 'USD')
    merchant = mock()
    marketplace = mock()
    marketplace.stubs(:uri).returns('')
    merchant.stubs(:marketplace).returns(marketplace)
    Balanced::Merchant.stubs(:me).returns(merchant)
  end

  context 'ingoing' do

    setup do
      @balanced_processor.ingoing_payment(@user)
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
        @balanced_processor.ingoing_payment(@user)
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

  end



  context '#payout' do

    setup do
      @company = FactoryGirl.create(:company)
      @company.update_attribute(:paypal_email, 'receiver@example.com')
      @company.instance.update_attribute(:paypal_email, 'sender@example.com')
    end

    context 'existing customer' do
      setup do 
        @instance_client = FactoryGirl.create(:instance_client, :client => @company, :balanced_user_id => 'test-customer')
        @customer = mock()
        @credit = mock()
        Balanced::Customer.expects(:find).with('test-customer').returns(@customer).at_least(1)
      end

      should "invoke the right callback on success" do
        @customer.stubs(:credit).returns(@credit)
        @credit.expects(:save).returns(stub(:status => 'pending', :to_yaml => 'yaml'))
        @balanced_processor.expects(:payout_successful)
        @balanced_processor.outgoing_payment(@company.instance, @company).process_payout(Money.new(1000, 'USD'))
      end

      should "invoke the right callback on failure" do
        @customer.stubs(:credit).returns(@credit)
        @credit.expects(:save).returns(stub(:status => 'failed', :to_yaml => 'yaml'))
        @balanced_processor.expects(:payout_failed)
        @balanced_processor.outgoing_payment(@company.instance, @company).process_payout(Money.new(1000, 'USD'))
      end

      should "invoke payout with the right arguments" do
        @credit.expects(:save).returns(stub(:status => 'paid', :to_yaml => 'yaml'))
        @customer.expects(:credit).with do |credit_hash| 
          credit_hash[:amount] == 1234 &&
            credit_hash[:description] == "Payout from Instance #{@company.instance.name}(id=#{@company.instance.id}) to Company #{@company.name} (id=#{@company.id})" &&
            credit_hash[:appears_on_statement_as] == "Payout from #{@company.instance.class.name}"
        end.returns(@credit)
        @balanced_processor.expects(:payout_successful)
        @balanced_processor.outgoing_payment(@company.instance, @company).process_payout(Money.new(1234, 'USD'))
      end

    end

    context 'create customer with bank acccount' do

      setup do
        @customer = mock()
        @bank_account = stub()
        Company.any_instance.expects(:create_bank_account_in_balanced).returns(true).at_least(0)
        @company = FactoryGirl.create(:company_with_balanced, {
          :bank_account_number => '123456789',
          :bank_routing_number => '123456789',
          :bank_owner_name => 'John Doe',
        })
        @bank_mock = mock()
        @customer.stubs(:add_bank_account).with(@bank_mock).returns({})
      end

      context 'correct creating bank account' do

        setup do
          Balanced::BankAccount.expects(:new).with(@company.balanced_bank_account_details).returns(stub(:save => @bank_mock))
        end

        should 'not try to invalidate old bank account if client has no balanced_user_id and just create it' do
          @company.instance_clients.destroy_all
          @customer.stubs(:uri).returns('new-test-customer')
          Balanced::Customer.expects(:find).never
          Balanced::Customer.expects(:new).returns(stub(:save => @customer)).once
          assert_difference 'InstanceClient.count' do
            Billing::Gateway::BalancedProcessor.create_customer_with_bank_account(@company)
            @instance_client = InstanceClient.last
            assert_equal @company.reload, @instance_client.client
            assert_equal @company.instance, @instance_client.instance
            assert_equal 'new-test-customer', @instance_client.balanced_user_id
          end
        end

        should 'try to invalidate old bank account if client has balanced_user_id' do
          @bank_account = mock()
          @bank_account.stubs(:is_valid).returns(false)
          @bank_account.expects(:invalidate).returns(true)
          @customer.stubs(:bank_accounts).returns(stub(:last => @bank_account))
          Balanced::Customer.expects(:find).with(@company.instance_clients.first.balanced_user_id).returns(@customer).twice
          Balanced::Customer.expects(:new).never
          assert_no_difference 'InstanceClient.count' do
            Billing::Gateway::BalancedProcessor.create_customer_with_bank_account(@company)
          end
        end

      end

      should 'raise exception if something goes wrong with invalidation' do
        @bank_account = mock()
        @bank_account.expects(:invalidate).returns(true)
        @bank_account.stubs(:is_valid).returns(true)
        @customer.stubs(:bank_accounts).returns(stub(:last => @bank_account))
        Balanced::Customer.expects(:find).returns(@customer).once
        assert_raise RuntimeError do |e|
          Billing::Gateway::BalancedProcessor.create_customer_with_bank_account(@company)
          assert e.message.include?('should have been invalidated')
        end
      end

    end
  end

  context 'is_supported?' do

    should 'be supported if instance_client with the right instance exists and has balanced_user_id' do
      @company = FactoryGirl.create(:company)
      FactoryGirl.create(:instance_client, :client => @company, :instance => @company.instance, :balanced_user_id => 'present')
      assert Billing::Gateway::BalancedProcessor.is_supported_by?(@company)
    end

    should 'not be supported if instance_client exists but for other instance' do
      @company = FactoryGirl.create(:company)
      FactoryGirl.create(:instance_client, :client => @company, :instance => FactoryGirl.create(:instance), :balanced_user_id => 'present')
      refute Billing::Gateway::BalancedProcessor.is_supported_by?(@company)
    end

    should 'not be supported if instance_client with the right instance exists but without balanced_user_id' do
      @company = FactoryGirl.create(:company)
      FactoryGirl.create(:instance_client, :client => @company, :instance => @company.instance)
      refute Billing::Gateway::BalancedProcessor.is_supported_by?(@company)
    end

    should 'not be supported if instance_client does not exist' do
      @company = FactoryGirl.create(:company)
      refute Billing::Gateway::BalancedProcessor.is_supported_by?(@company)
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

