require 'test_helper'

class Utils::DefaultAlertsCreator::PaymentGatewayCreatorTest < ActionDispatch::IntegrationTest
  setup do
    @payment_gateway_creator = Utils::DefaultAlertsCreator::PaymentGatewayCreator.new
  end

  should 'create all' do
    @payment_gateway_creator.expects(:create_notify_host_about_merchant_account_approved_email!).once
    @payment_gateway_creator.expects(:create_notify_host_about_merchant_account_declined_email!).once
    @payment_gateway_creator.expects(:create_notify_host_about_merchant_account_requirements_email!).once
    @payment_gateway_creator.expects(:create_notify_host_about_payout_failure_email!).once
    @payment_gateway_creator.create_all!
  end

  context 'methods' do
    setup do
      ActiveMerchant::Billing::BraintreeCustomGateway.any_instance.stubs(:onboard!).returns(OpenStruct.new(success?: true))
      @merchant_account = FactoryGirl.create(:braintree_marketplace_merchant_account)
      @platform_context = PlatformContext.current
      @instance = @platform_context.instance
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, name: 'custom.domain.com'))
    end

    should 'create_notify_host_about_merchant_account_approved_email!' do
      @payment_gateway_creator.create_notify_host_about_merchant_account_approved_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountApproved, @merchant_account.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_equal [@merchant_account.merchantable.creator.email], mail.to

      assert_contains "Congratulations, #{ @merchant_account.merchantable.creator.first_name }!", mail.html_part.body
      assert_contains 'Your payout information has been approved.', mail.html_part.body
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_equal 'Your payout information has been approved', mail.subject
    end

    should 'create_notify_host_about_merchant_account_declined_email!' do
      @payment_gateway_creator.create_notify_host_about_merchant_account_declined_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountDeclined, @merchant_account.id, 'Epic fail')
      end
      mail = ActionMailer::Base.deliveries.last
      assert_equal [@merchant_account.merchantable.creator.email], mail.to
      assert_contains "We are sorry, #{@merchant_account.merchantable.creator.first_name}!", mail.html_part.body
      assert_contains 'Reason: Epic fail', mail.html_part.body
      assert_contains 'https://custom.domain.com/dashboard/company/payouts/edit', mail.html_part.body
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_equal 'Your payout information has been declined', mail.subject
    end

    should 'create_notify_host_about_merchant_account_requirements_email!' do
      @payment_gateway_creator.create_notify_host_about_merchant_account_requirements_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountPending, @merchant_account.id, 'Epic fail')
      end

      mail = ActionMailer::Base.deliveries.last
      assert_equal [@merchant_account.merchantable.creator.email], mail.to
      assert_contains "Congratulations, #{@merchant_account.merchantable.creator.first_name}!", mail.html_part.body
      assert_contains 'https://custom.domain.com/dashboard/company/payouts/edit', mail.html_part.body
      assert_not_contains 'Liquid error:', mail.html_part.body
      assert_equal 'Please provide required information', mail.subject
    end

    context 'create_notify_host_about_payout_failure_email!' do
      setup do
        @payment_gateway_creator.create_notify_host_about_payout_failure_email!
      end

      should 'contain link to update payout if follow up action suggests this' do
        @date = Date.current
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(
            WorkflowStep::PaymentGatewayWorkflow::DisbursementFailed,
            @merchant_account.id,
            'exception_message' => 'epic_fail',
            'follow_up_action' => 'update_funding_information',
            'amount' => 100.0,
            'disbursement_date' => @date,
            'transaction_ids' => [1, 2, 3]
          )
        end
        mail = ActionMailer::Base.deliveries.last
        assert_contains "We are sorry, #{@merchant_account.merchantable.creator.first_name}!", mail.html_part.body
        assert_contains "Unfortunately we were not able to deliver you automated payout, which was triggered on #{ I18n.l(@date, format: :long)} due to the following reason: Epic fail", mail.html_part.body

        assert_contains 'The issue will not be resolved without your action', mail.html_part.body
        assert_contains 'https://custom.domain.com/dashboard/company/payouts/edit', mail.html_part.body
        assert_equal [@merchant_account.merchantable.creator.email], mail.to
        assert_not_contains 'href="https://example.com', mail.html_part.body
        assert_not_contains 'href="/', mail.html_part.body
        assert_equal 'Automatic payout failed', mail.subject
      end

      should 'not contain link to update payout if follow up does not suggests this' do
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::DisbursementFailed, @merchant_account.id,             'exception_message' => 'epic_fail',
                                                                                                                              'follow_up_action' => 'some_other_info',
                                                                                                                              'amount' => 100.0,
                                                                                                                              'disbursement_date' => Date.current,
                                                                                                                              'transaction_ids' => [1, 2, 3])
        end
        mail = ActionMailer::Base.deliveries.last
        assert_contains 'Suggested follow up action: Some other info', mail.html_part.body
        assert_not_contains 'The issue will not be resolved without your action', mail.html_part.body
        assert_not_contains 'https://custom.domain.com/dashboard/company/payouts/edit', mail.html_part.body
        assert_equal [@merchant_account.merchantable.creator.email], mail.to
      end
    end
  end
end
