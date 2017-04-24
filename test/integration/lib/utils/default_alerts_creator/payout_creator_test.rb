# frozen_string_literal: true
require 'test_helper'
require 'helpers/reservation_test_support'

class Utils::DefaultAlertsCreator::PayoutTest < ActionDispatch::IntegrationTest
  include ReservationTestSupport

  setup do
    @company_owner = FactoryGirl.create(:user_with_sms_notifications_enabled, mobile_number: '124456789')
    User.any_instance.stubs(:temporary_token).returns('abc')
    @instance = FactoryGirl.create(:instance, name: 'MyBoat')
    @domain = FactoryGirl.create(:domain, name: 'notifcations.com', target: @instance)
    @company = FactoryGirl.create(:company, creator: @company_owner)
    @company.update_column(:instance_id, @instance.id)
    @company.creator.update_column(:instance_id, @instance.id)
    PlatformContext.current = PlatformContext.new(@company)
    Company.any_instance.stubs(:created_payment_transfers).returns([
                                                                     PaymentTransfer.new(amount_cents: 7887, currency: 'USD'),
                                                                     PaymentTransfer.new(amount_cents: 4650, currency: 'EUR')
                                                                   ])
    @payout_creator = Utils::DefaultAlertsCreator::PayoutCreator.new
  end

  should 'create verification email' do
    @payout_creator.create_notify_host_of_no_pyout_option_email!
    assert_difference 'ActionMailer::Base.deliveries.size' do
      WorkflowStepJob.perform(WorkflowStep::PayoutWorkflow::NoPayoutOption, @company.id, @company.created_payment_transfers)
    end
    mail = ActionMailer::Base.deliveries.last
    assert mail.html_part.body.include?('You earned 78.87$, 46.50€'), "Did not include correct information about earnings:\n#{mail.html_part.body}"
    assert mail.html_part.body.include?('But first, we need you'), "Did not include correct copy:\n#{mail.html_part.body}"
    assert mail.html_part.body.include?('https://notifcations.com/dashboard/notification_preferences/edit'), "Did not include correct url to add paypal form:\n#{mail.html_part.body}"
    assert_equal [@company.creator.email], mail.to
  end

  context 'payout sms' do
    setup do
      Googl.stubs(:shorten).with('https://notifcations.com/dashboard/company/payouts/edit?temporary_token=abc#company_paypal_email').returns(stub(short_url: 'http://goo.gl/abf324'))
      @payout_creator.create_notify_host_of_no_pyout_option_sms!
    end

    should 'create notify host of payout sms' do
      sms = WorkflowAlert::SmsInvoker.new(WorkflowAlert.where(alert_type: 'sms').last).invoke!(WorkflowStep::PayoutWorkflow::NoPayoutOption.new(@company.id, @company.created_payment_transfers))
      assert_equal @company_owner.full_mobile_number, sms.to
      assert sms.body =~ Regexp.new('Hi from MyBoat. Your funds transfer is ready. Please add a PayPal account to receive your funds now.'), "Sms body does not include expected content: #{sms.body}"
      assert sms.body =~ /http:\/\/goo.gl/
    end

    should 'trigger proper sms' do
      WorkflowAlert::SmsInvoker.expects(:new).with(WorkflowAlert.where(alert_type: 'sms').last, metadata: {}).returns(stub(invoke!: true)).once
      WorkflowStepJob.perform(WorkflowStep::PayoutWorkflow::NoPayoutOption, @company.id, @company.created_payment_transfers)
    end
  end
end
