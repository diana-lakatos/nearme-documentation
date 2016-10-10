require 'test_helper'

class Utils::DefaultAlertsCreator::SupportCreatorTest < ActionDispatch::IntegrationTest
  setup do
    @support_creator = Utils::DefaultAlertsCreator::SupportCreator.new
  end

  should 'create all' do
    @support_creator.expects(:create_request_received_email!).once
    @support_creator.expects(:create_support_received_email!).once
    @support_creator.expects(:create_request_updated_email!).once
    @support_creator.expects(:create_support_updated_email!).once
    @support_creator.expects(:create_request_replied_email!).once
    @support_creator.create_all!
  end

  context 'methods' do
    setup do
      @user = FactoryGirl.create(:user)
      @ticket = FactoryGirl.create(:support_ticket, user: @user)
      @message = FactoryGirl.create(:support_ticket_message, user: @user, ticket: @ticket)
      @platform_context = PlatformContext.current
      @instance_admin = FactoryGirl.create(:instance_admin)
      @instance = @platform_context.instance
      InstanceAdmin.create(user_id: @user.id).update_attribute(:instance_id, @instance.id)
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, name: 'custom.domain.com'))
    end

    should 'create_request_received_email' do
      @support_creator.create_request_received_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::SupportWorkflow::Created, @message.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert mail.html_part.body.include?('I have a lot of questions. Where to start.')
      assert mail.html_part.body.include?('Request Received')
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_equal [@user.email], mail.to
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_equal "[Ticket Support #{@message.ticket_id}] #{@platform_context.decorate.name} - Your support request has been received", mail.subject
    end

    should 'create_request_updated_email' do
      @support_creator.create_request_updated_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::SupportWorkflow::Updated, @message.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert mail.html_part.body.include?('I have a lot of questions. Where to start.')
      assert_equal [@user.email], mail.to
      assert mail.html_part.body.include?('Ticket Updated')
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_equal "[Ticket Support #{@message.ticket_id}] #{@platform_context.decorate.name} - Your support request was updated", mail.subject
    end

    should 'create_request_replied_email' do
      @support_creator.create_request_replied_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::SupportWorkflow::Replied, @message.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert mail.html_part.body.include?('I have a lot of questions. Where to start.')
      assert mail.html_part.body.include?('has replied to your support request.')
      assert_equal [@user.email], mail.to
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_equal "[Ticket Support #{@message.ticket_id}] #{@platform_context.decorate.name} - #{@message.full_name} replied to your support request", mail.subject
    end

    context 'support' do
      setup do
        @instance_admin = FactoryGirl.create(:instance_admin)
      end
    end

    should 'create_support_received_email!' do
      @support_creator.create_support_received_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::SupportWorkflow::Created, @message.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert mail.html_part.body.include?('I have a lot of questions. Where to start.')
      assert mail.html_part.body.include?('New Support Request')
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_equal InstanceAdminRole.first.instance_admins.all.map(&:user).map(&:email).sort, mail.to.sort
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_equal "[Ticket Support #{@message.ticket_id}] #{@platform_context.decorate.name} - #{@message.full_name} has submited a support request", mail.subject
    end

    should 'create_support_updated_email!' do
      @support_creator.create_support_updated_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::SupportWorkflow::Updated, @message.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert mail.html_part.body.include?('I have a lot of questions. Where to start.')
      assert_equal InstanceAdminRole.first.instance_admins.all.map(&:user).map(&:email).sort, mail.to.sort
      assert mail.html_part.body.include?('Ticket Updated')
      assert mail.html_part.body.include?("#{@message.full_name} has updated ticket ##{@message.ticket_id}")
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_equal "[Ticket Support #{@message.ticket_id}] #{@platform_context.decorate.name} - #{@message.full_name} has updated their support request", mail.subject
    end
  end
end
