require 'test_helper'

class Billing::Gateway::Processor::Outgoing::BalancedTest < ActiveSupport::TestCase
  setup do
    @instance = Instance.first

    @instance.instance_payment_gateways << FactoryGirl.create(:balanced_instance_payment_gateway)
    @instance.instance_payment_gateways.set_settings_for(:balanced, {api_key: 'test_key'})

    @company = FactoryGirl.create(:company)
    @company.update_attribute(:paypal_email, 'receiver@example.com')

    @instance.instance_payment_gateways << FactoryGirl.create(:paypal_instance_payment_gateway)
    @company.instance.instance_payment_gateways.set_settings_for(:paypal, {email: 'sender@example.com'})

    @balanced_processor = Billing::Gateway::Processor::Outgoing::Balanced.new(@company, 'USD')
    merchant = mock()
    marketplace = mock()
    marketplace.stubs(:uri).returns('')
    merchant.stubs(:marketplace).returns(marketplace)
    Balanced::Merchant.stubs(:me).returns(merchant)
  end


  context '#payout' do

    context 'existing customer' do
      setup do
        @instance_client = FactoryGirl.create(:instance_client, :client => @company, :balanced_user_id => 'test-customer')
        @customer = mock()
        @credit = mock()
        Balanced::Customer.expects(:find).with('test-customer').returns(@customer).at_least(1)
      end

      should "raise error if not USD" do
        Balanced::Customer.unstub(:find)
        assert_raise Billing::Gateway::Processor::Base::InvalidStateError do
          @balanced_processor.process_payout(Money.new(1000, 'EUR'))
        end
      end

      should "invoke the right callback on success" do
        @customer.stubs(:credit).returns(@credit)
        @credit.expects(:save).returns(stub(:status => 'pending', :to_yaml => 'yaml'))
        @balanced_processor.expects(:payout_pending)
        @balanced_processor.process_payout(Money.new(1000, 'USD'))
      end

      should "invoke the right callback on failure" do
        @customer.stubs(:credit).returns(@credit)
        @credit.expects(:save).returns(stub(:status => 'failed', :to_yaml => 'yaml'))
        @balanced_processor.expects(:payout_failed)
        @balanced_processor.process_payout(Money.new(1000, 'USD'))
      end

      should "invoke payout with the right arguments" do
        @credit.expects(:save).returns(stub(:status => 'paid', :to_yaml => 'yaml'))
        @customer.expects(:credit).with do |credit_hash|
          credit_hash[:amount] == 1234 &&
          credit_hash[:description] == "Payout from Instance(id=#{@company.instance.id}) #{@company.instance.name} to Company(id=#{@company.id}) #{@company.name}" &&
          credit_hash[:appears_on_statement_as] == @company.instance.name
        end.returns(@credit)
        @balanced_processor.expects(:payout_pending)
        @balanced_processor.process_payout(Money.new(1234, 'USD'))
      end

    end

    context 'create customer with bank acccount' do

      setup do
        @customer = mock()
        @bank_account = stub()
        Company.any_instance.expects(:create_bank_account_in_balanced!).returns(true).at_least(0)
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
            Billing::Gateway::Processor::Outgoing::Balanced.create_customer_with_bank_account!(@company)
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
            Billing::Gateway::Processor::Outgoing::Balanced.create_customer_with_bank_account!(@company)
          end
        end

      end

      should 'raise exception if something goes wrong with invalidation' do
        @bank_account = mock()
        @bank_account.expects(:invalidate).returns(true)
        @bank_account.stubs(:is_valid).returns(true)
        @customer.stubs(:bank_accounts).returns(stub(:last => @bank_account))
        Balanced::Customer.expects(:find).returns(@customer).once
        assert_raise Billing::Gateway::Processor::Base::InvalidStateError do |e|
          Billing::Gateway::Processor::Outgoing::Balanced.create_customer_with_bank_account!(@company)
          assert e.message.include?('should have been invalidated')
        end
      end

    end
  end

end

