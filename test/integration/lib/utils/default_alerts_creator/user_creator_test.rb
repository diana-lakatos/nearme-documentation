require 'test_helper'

class Utils::DefaultAlertsCreator::UserCreatorTest < ActionDispatch::IntegrationTest
  setup do
    @user_creator = Utils::DefaultAlertsCreator::UserCreator.new
  end

  should 'create all' do
    @user_creator.expects(:create_unread_messages_email!).once
    @user_creator.expects(:create_user_promoted_email!).once
    @user_creator.create_all!
  end

  context 'methods' do
    setup do
      @user = FactoryGirl.create(:user, name: 'John Doe')
      @platform_context = PlatformContext.current
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, name: 'custom.domain.com'))
    end

    should 'create_unread_messages_email' do
      @user_creator.create_unread_messages_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::UserWorkflow::UnreadMessages, @user.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_equal 'You have unread messages', mail.subject
      assert mail.html_part.body.include?('This is a notification to let you know you have unread messages waiting for you in your inbox')
      assert_equal [@user.email], mail.to
      assert_contains 'href="http://custom.domain.com', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end

    should 'create_user_promoted_email' do
      @user_creator.create_user_promoted_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::UserWorkflow::PromotedToAdmin, @user.id, FactoryGirl.create(:user, name: 'Super Admin').id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_equal "You've become an Admin of #{PlatformContext.current.instance.name}", mail.subject
      assert mail.html_part.body.include?('You have been promoted to Admin by Super Admin')
      assert_equal [@user.email], mail.to
      assert_contains 'href="https://custom.domain.com/instance_admin', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end
  end
end
