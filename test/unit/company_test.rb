require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  should belong_to(:creator)
  should have_many(:locations)
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

  should 'be valid even if its location is not valid' do
    @location = FactoryGirl.create(:location, company: @company)
    @location.address = nil
    @location.save(validate: false)
    @company.reload
    assert @company.valid?
  end

  context 'white label settings' do
    setup do
      @company = FactoryGirl.create(:company)
      @company.theme = FactoryGirl.create(:theme)
      FactoryGirl.create(:domain, target: @company)
      @company.save!
      @company.reload
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
        PlatformContext.current = PlatformContext.new(@company)
      end

      should 'notify host via sms and email if company has no payout option and instance supports payouts' do
        @created_payment_transfers = [mock(id: 1)]
        @company.stubs(:created_payment_transfers).returns(@created_payment_transfers)
        WorkflowStepJob.expects(:perform).with(::WorkflowStep::PayoutWorkflow::NoPayoutOption, @company.id, [1]).once
        @company.schedule_payment_transfer
      end

      should 'not notify host via sms and email if payment transfers are empty' do
        @created_payment_transfers = []
        @company.stubs(:created_payment_transfers).returns(@created_payment_transfers)
        WorkflowStepJob.expects(:perform).with(::WorkflowStep::PayoutWorkflow::NoPayoutOption, @company.id, @created_payment_transfers).never
        @company.schedule_payment_transfer
      end

      should 'not notify host via sms and email if mailing address present' do
        @created_payment_transfers = [mock]
        @company.stubs(:created_payment_transfers).returns(@created_payment_transfers)
        @company.stubs(:mailing_address).returns('address')
        WorkflowStepJob.expects(:perform).with(::WorkflowStep::PayoutWorkflow::NoPayoutOption, @company.id, @created_payment_transfers).never
        @company.schedule_payment_transfer
      end
    end
  end

  context 'iso_country_code' do
    setup do
      Address.destroy_all
      @company.reload
    end

    context 'without default on instance' do
      should 'return nil if company has no address' do
        assert_equal nil, @company.iso_country_code
      end
    end

    context 'with default on instance' do
      setup do
        @company.instance.update_attribute(:default_country, 'Poland')
      end

      should 'return instance country code if not  present' do
        @company.iso_country_code
        assert_equal 'PL', @company.iso_country_code
      end

      should 'return address country if present' do
        FactoryGirl.create(:address, entity: @company)
        assert_equal 'US', @company.iso_country_code
      end
    end
  end
end
