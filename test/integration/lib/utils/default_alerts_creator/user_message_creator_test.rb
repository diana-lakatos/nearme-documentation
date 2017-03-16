# frozen_string_literal: true
require 'test_helper'

class Utils::DefaultAlertsCreator::UserMessageCreatorTest < ActionDispatch::IntegrationTest
  setup do
    @user_message_creator = Utils::DefaultAlertsCreator::UserMessageCreator.new
  end

  should 'create all' do
    @user_message_creator.expects(:create_user_transactable_message_from_lister_email!).once
    @user_message_creator.expects(:create_user_transactable_message_from_enquirer_email!).once
    @user_message_creator.expects(:create_user_message_created_sms!).once
    @user_message_creator.create_all!
  end

  context 'methods' do
    setup do
      @user_message = FactoryGirl.create(:user_message)
    end

    should 'create_user_message_from_lister' do
      @user_message_creator.create_user_transactable_message_from_lister_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::UserMessageWorkflow::TransactableMessageFromLister, @user_message.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains "#{@user_message.author.first_name} wrote: \"#{@user_message.body}\"", mail.html_part.body
      assert_equal [@user_message.recipient.email], mail.to
      assert_equal "[#{PlatformContext.current.decorate.name}] You received a message!", mail.subject
    end

    should 'create_user_message_from_enquirer' do
      @user_message_creator.create_user_transactable_message_from_enquirer_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::UserMessageWorkflow::TransactableMessageFromEnquirer, @user_message.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains "#{@user_message.author.first_name} wrote: \"#{@user_message.body}\"", mail.html_part.body
      assert_equal [@user_message.recipient.email], mail.to
      assert_equal "[#{PlatformContext.current.decorate.name}] You received a message!", mail.subject
      assert_not_contains 'Liquid error', mail.html_part.body
    end

    context 'sms' do
      setup do
        @instance = FactoryGirl.create(:instance, name: 'DesksNearMe')
        @domain = FactoryGirl.create(:domain, name: 'notifcations.com', target: @instance)
        PlatformContext.current = PlatformContext.new(@instance)
        @author = FactoryGirl.create(:user_with_sms_notifications_enabled, name: 'Krzysztof Test')
        @recipient = FactoryGirl.create(:user_with_sms_notifications_enabled, mobile_number: '124456789')
        @recipient.stubs(:temporary_token).returns('abc')
        @user_message = FactoryGirl.create(:user_message,
                                           thread_context: @recipient,
                                           thread_owner: @author,
                                           author: @author,
                                           thread_recipient: @recipient,
                                           body: 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum.')
        Googl.stubs(:shorten).with("https://notifcations.com/users/#{@recipient.id}/user_messages/#{@user_message.id}?token=abc").returns(stub(short_url: 'http://goo.gl/abc324'))
        UserMessage.any_instance.stubs(:recipient).returns(@recipient)
      end

      context 'create_user_message_from_lister_sms!' do
        setup do
          @user_message_creator.create_user_message_created_sms!
        end

        should 'trigger proper sms' do
          WorkflowAlert::SmsInvoker.expects(:new).with(WorkflowAlert.where(alert_type: 'sms').last).returns(stub(invoke!: true)).once
          WorkflowStepJob.perform(WorkflowStep::UserMessageWorkflow::Created, @user_message.id)
        end

        should 'render with the user_message' do
          sms = WorkflowAlert::SmsInvoker.new(WorkflowAlert.where(alert_type: 'sms').last).invoke!(WorkflowStep::UserMessageWorkflow::Created.new(@user_message.id))
          assert_equal @recipient.full_mobile_number, sms.to
          assert sms.body =~ /\[DesksNearMe\] New message from Krzysztof: \"Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invid...\"/i, "Sms body does not include expected content: #{sms.body}"
          assert sms.body =~ /http:\/\/goo.gl\/abc324/
        end

        should 'not render if user had disabled sms notification for new messages' do
          @recipient.update_attribute(:sms_notifications_enabled, false)
          sms = WorkflowAlert::SmsInvoker.new(WorkflowAlert.where(alert_type: 'sms').last).invoke!(WorkflowStep::UserMessageWorkflow::Created.new(@user_message.id))
          assert sms.is_a?(SmsNotifier::NullMessage)
          refute sms.deliver
        end
      end
    end
  end
end
