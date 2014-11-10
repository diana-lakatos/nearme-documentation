require 'test_helper'

class CompanyTest < ActiveSupport::TestCase

  should belong_to(:creator)
  should have_many(:locations)
  should have_many(:industries)
  should validate_presence_of(:name)
  should_not allow_value('not_an_email').for(:email)
  should allow_value('an_email@domain.com').for(:email)
  should_not allow_value('not a url!').for(:url)
  should allow_value('http://a-url.com').for(:url)
  should allow_value('a-url.com').for(:url)
  should ensure_length_of(:description).is_at_most(250)

  setup do
    @company = FactoryGirl.create(:company)
  end

  should "be valid even if its location is not valid" do
    @location = FactoryGirl.create(:location, :company => @company)
    @location.address = nil
    @location.save(:validate => false)
    @company.reload
    assert @company.valid?
  end

  context 'white label settings' do
    setup do
      @company = FactoryGirl.create(:company)
      @company.theme = FactoryGirl.create(:theme)
      FactoryGirl.create(:domain, {target: @company})
      @company.save!
    end
    should 'know when white label settings are enabled' do
      @company.update_attribute(:white_label_enabled, true)
      assert @company.white_label_enabled?
      assert @company.domain.white_label_enabled?
    end

    should 'know when white label settings are disabled' do
      @company.update_attribute(:white_label_enabled, false)
      assert !@company.white_label_enabled?
      assert !@company.domain.white_label_enabled?
    end
  end

  context 'schedule_payment_transfer' do

    context 'no payout address' do
      setup do
        stub_mixpanel
        PlatformContext.current = PlatformContext.new(@company)
      end

      should 'notify host via sms and email if company has no payout option and instance supports payouts' do
        @company.stubs(:created_payment_transfers).returns([mock()])
        @mock = mock()
        @mock.expects(:deliver).once
        CompanySmsNotifier.expects(:notify_host_of_no_payout_option).with(@company).returns(stub(deliver: true)).once
        CompanyMailer.expects(:notify_host_of_no_payout_option).with(@company).returns(@mock)
        @company.schedule_payment_transfer
      end

      should 'not notify host via sms and email if mailing address present' do
        @company.stubs(:created_payment_transfers).returns([mock()])
        @company.stubs(:mailing_address).returns('address')
        CompanySmsNotifier.expects(:notify_host_of_no_payout_option).never
        CompanyMailer.expects(:notify_host_of_no_payout_option).never
        @company.schedule_payment_transfer
      end

      should 'not notify host via sms and email if company has payout option' do
        @company.stubs(:created_payment_transfers).returns([])
        CompanySmsNotifier.expects(:notify_host_of_no_payout_option).never
        CompanyMailer.expects(:notify_host_of_no_payout_option).never
        @company.schedule_payment_transfer
      end

    end

  end

  context 'provide bank account details' do

    setup do
      @company = FactoryGirl.create(:company)
      @company.attributes = {
        :bank_account_number => '123456789', 
        :bank_routing_number => '987654321', 
        :bank_owner_name => 'John Doe'
      }
    end

      should 'know last four digits' do
        assert_equal '6789', @company.last_four_digits_of_bank_account
      end

      should 'return correct bank account details' do
        expected_details = {
          :account_number => '123456789', 
          :bank_code => '987654321', 
          :name => 'John Doe',
          :type => 'checking'
        }
        assert_equal expected_details, @company.balanced_bank_account_details
      end

      should 'try to store bank account' do
        Billing::Gateway::Processor::Outgoing::Balanced.expects(:create_customer_with_bank_account!).with do |company|
          company.id == @company.id
        end.returns(true).once
        assert @company.save
      end

      should 'handle inability to invalidate old account' do
        Billing::Gateway::Processor::Outgoing::Balanced.expects(:create_customer_with_bank_account!).raises(RuntimeError.new("Bank account should have been invalidated, but it's still valid for InstanceClient(id=1)"))
        refute @company.save
        assert @company.errors.include?(:bank_account_form)
      end

      context 'information missing' do

        should 'not store information if no bank account_number' do
          @company.bank_account_number = nil
          Billing::Gateway::Processor::Outgoing::Balanced.expects(:create_customer_with_bank_account!).never
          refute @company.save
          assert @company.errors.include?(:bank_account_number)
        end

        should 'not store information if no bank routing_number' do
          @company.bank_routing_number = ''
          Billing::Gateway::Processor::Outgoing::Balanced.expects(:create_customer_with_bank_account!).never
          refute @company.save
          assert @company.errors.include?(:bank_routing_number)
        end

        should 'not store information if no bank name' do
          @company.bank_owner_name = ''
          Billing::Gateway::Processor::Outgoing::Balanced.expects(:create_customer_with_bank_account!).never
          refute @company.save
          assert @company.errors.include?(:bank_owner_name)
        end

      end
  end

  context 'metadata' do
    context 'populate_industries_metadata!' do
      setup do
        @company = FactoryGirl.create(:company)
        @industry = FactoryGirl.create(:industry, :name => 'test')
        @company.industries = [@industry]
        @company.save!
      end

      should 'populate correct instance_admin hash' do
        @company.expects(:update_metadata).with({ 
          :industries_metadata => ['test']
        })
        @company.populate_industries_metadata!
      end
    end
  end
end
