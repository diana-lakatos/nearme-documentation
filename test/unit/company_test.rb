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
        @company.stubs(:has_payment_method?).returns(false)
        @mock = mock()
        @mock.expects(:deliver).twice
        stub_mixpanel
      end

      should 'notify host via sms and email if company has no payout option' do
        CompanySmsNotifier.expects(:notify_host_of_no_payout_option).with(@company).returns(@mock)
        CompanyMailer.expects(:notify_host_of_no_payout_option).with(@company).returns(@mock)
        @company.schedule_payment_transfer
      end

    end

  end

  context 'payout option' do

    should 'have no payout option if paypal email and mailing address are not set' do
      @company.stubs(:mailing_address).returns(nil)
      @company.stubs(:paypal_email).returns(nil)
      refute @company.has_payment_method?
    end

    should 'have payout option if paypal email is  set' do
      @company.stubs(:mailing_address).returns(nil)
      @company.stubs(:paypal_email).returns('paypal@example.com')
      assert @company.has_payment_method?
    end

    should 'have payout option if mailing address is set' do
      @company.stubs(:mailing_address).returns('San Francisco, Some street 123')
      @company.stubs(:paypal_email).returns(nil)
      assert @company.has_payment_method?
    end

  end
end
