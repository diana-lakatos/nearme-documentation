require 'test_helper'

class Utils::DefaultAlertsCreator::RfqCreatorTest < ActionDispatch::IntegrationTest
  setup do
    @rfq_creator = Utils::DefaultAlertsCreator::RfqCreator.new
  end

  should 'create all' do
    @rfq_creator.expects(:create_request_received_email!).once
    @rfq_creator.expects(:create_support_received_email!).once
    @rfq_creator.expects(:create_request_updated_email!).once
    @rfq_creator.expects(:create_support_updated_email!).once
    @rfq_creator.expects(:create_request_replied_email!).once
    @rfq_creator.create_all!
  end

  context 'methods' do
    setup do
      @user = FactoryGirl.create(:user)
      @transactable = FactoryGirl.create(:transactable)
      @ticket = FactoryGirl.create(:support_ticket, user: @user, assigned_to: @transactable.creator, target: @transactable)
      @message = @ticket.messages.first
      @platform_context = PlatformContext.current
      @instance_admin = FactoryGirl.create(:instance_admin)
      @instance = @platform_context.instance
      InstanceAdmin.create(user_id: @user.id).update_attribute(:instance_id, @instance.id)
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, name: 'custom.domain.com'))
    end

    should 'create_request_received_email' do
      @rfq_creator.create_request_received_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RfqWorkflow::Created, @message.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert mail.html_part.body.include?('I have a lot of questions. Where to start.')
      assert mail.html_part.body.include?('Offer Received')
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_equal [@message.ticket.user.email], mail.to
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_equal 'Your Request for Quote has been received', mail.subject
    end

    should 'create_request_updated_email' do
      @rfq_creator.create_request_updated_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RfqWorkflow::Updated, @message.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert mail.html_part.body.include?('I have a lot of questions. Where to start.')
      assert_equal [@message.ticket.user.email], mail.to
      assert mail.html_part.body.include?('Offer Updated')
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_equal 'Your Request for Quote was updated', mail.subject
    end

    should 'create_request_replied_email' do
      @rfq_creator.create_request_replied_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RfqWorkflow::Replied, @message.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert mail.html_part.body.include?('I have a lot of questions. Where to start.')
      assert mail.html_part.body.include?('has replied to your offer.')
      assert_equal [@message.ticket.user.email], mail.to
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_equal "#{@message.full_name} replied to your Request for Quote", mail.subject
    end

    should 'create_support_received_email!' do
      @rfq_creator.create_support_received_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RfqWorkflow::Created, @message.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert mail.html_part.body.include?('I have a lot of questions. Where to start.')
      assert mail.html_part.body.include?('New Offer')
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_equal [@transactable.creator.email], mail.to
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_equal "#{@message.full_name} has submited a Request for Quote", mail.subject
    end

    should 'create_support_updated_email!' do
      @rfq_creator.create_support_updated_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RfqWorkflow::Updated, @message.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert mail.html_part.body.include?('I have a lot of questions. Where to start.')
      assert_equal [@transactable.creator.email], mail.to
      assert mail.html_part.body.include?('Offer Updated')
      assert_equal "#{@message.full_name} has updated their Request for Quote", mail.subject
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_equal "#{@message.full_name} has updated their Request for Quote", mail.subject
    end
  end
end
