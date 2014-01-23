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
      @company.domain = FactoryGirl.create(:domain)
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
      end

      should 'notify host via sms and email if company has no payout option and instance supports payouts' do
        @company.stubs(:created_payment_transfers).returns([mock()])
        @mock = mock()
        @mock.expects(:deliver).twice
        CompanySmsNotifier.expects(:notify_host_of_no_payout_option).with(@company).returns(@mock)
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

  context 'update balanced info' do

    setup do
      @company = FactoryGirl.create(:company_with_balanced)
    end

    should 'have assigned timestamp' do
      assert @company.balanced_account_details_changed_at.present?
    end

    should 'update timestamp of updating balanced info when account_number changed' do
      @company.balanced_account_number = '123456789'
      Timecop.freeze(Time.zone.now) do
        @company.save!
        assert_equal Time.zone.now.to_i, @company.balanced_account_details_changed_at.to_i
      end
    end

    should 'update timestamp of updating balanced info when bank_code changed' do
      @company.balanced_bank_code = '123456789'
      Timecop.freeze(Time.zone.now) do
        @company.save!
        assert_equal Time.zone.now.to_i, @company.balanced_account_details_changed_at.to_i
      end
    end

    should 'update timestamp of updating balanced info when balanced_name changed' do
      @company.balanced_name = 'John Updated'
      Timecop.freeze(Time.zone.now) do
        @company.save!
        assert_equal Time.zone.now.to_i, @company.balanced_account_details_changed_at.to_i
      end
    end

    should 'not update timestamp of updating balanced info when name changed' do
      @company.name = 'Cool Updated Company'
      @old_time_stamp = @company.balanced_account_details_changed_at
      Timecop.freeze(Time.zone.now + 10.minutes) do
        @company.save!
        assert_not_equal Time.zone.now.to_i, @company.balanced_account_details_changed_at.to_i
        assert_equal @old_time_stamp.to_i, @company.balanced_account_details_changed_at.to_i
      end
    end
  end
end
