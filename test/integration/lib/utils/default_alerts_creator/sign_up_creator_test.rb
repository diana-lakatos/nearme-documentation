# frozen_string_literal: true
require 'test_helper'

class Utils::DefaultAlertsCreator::SignupCreatorTest < ActionDispatch::IntegrationTest
  setup do
    @signup_creator = Utils::DefaultAlertsCreator::SignUpCreator.new
  end

  should 'create all' do
    @signup_creator.expects(:create_email_verification_email!).once
    @signup_creator.expects(:create_welcome_email!).once
    @signup_creator.expects(:create_create_user_by_admin_email!).once
    @signup_creator.expects(:create_notify_of_wrong_phone_number_email!).once
    @signup_creator.expects(:create_create_user_via_bulk_uploader_email!).once
    @signup_creator.expects(:create_approved_email!).once
    @signup_creator.create_all!
  end

  context 'methods' do
    setup do
      @user = FactoryGirl.create(:user)
      @platform_context = PlatformContext.current
      @instance = @platform_context.instance
      InstanceAdmin.create(user_id: @user.id).update_attribute(:instance_id, @instance.id)
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, name: 'custom.domain.com'))
    end

    should 'create verification email' do
      @signup_creator.create_email_verification_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::AccountCreated, @user.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains "/api/users/#{@user.id}/verify?token=#{UserVerificationForm.new(@user).email_verification_token}", mail.html_part.body
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert mail.subject.include?(@platform_context.decorate.name), "#{@platform_context.decorate.name} not included in:\n#{mail.subject}"
    end

    should 'create welcome email' do
      @signup_creator.create_welcome_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::AccountCreated, @user.id)
      end
      mail = ActionMailer::Base.deliveries.last
      subject = "#{@user.first_name}, welcome to #{@platform_context.decorate.name}!"

      assert mail.html_part.body.include?(@user.first_name)
      assert mail.html_part.body.include?("We are excited to welcome you to #{@platform_context.decorate.name}")
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_equal subject, mail.subject
    end

    context 'when sending invitation email' do
      setup do
        @new_user_token = 'new_user--token'
        @creator_token = 'creator--token'
        User.any_instance.stubs(:temporary_token).returns(@new_user_token, @creator_token)
        @signup_creator.create_create_user_by_admin_email!
        @creator = FactoryGirl.create(:user)
      end

      should 'create_create_user_by_admin_email' do
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::CreatedByAdmin, @user.id, @creator.id)
        end
        mail = ActionMailer::Base.deliveries.last
        assert mail.html_part.body.include?(@user.first_name)
        assert_equal [@user.email], mail.to
        assert_equal "#{@user.first_name}, you were invited to #{@platform_context.decorate.name} by #{@creator.name}!", mail.subject
        assert_contains "Welcome, #{@user.first_name}!", mail.html_part.body
        assert_contains "You have been invited by #{@creator.name} to join #{@platform_context.decorate.name}!", mail.html_part.body
        assert_contains 'href="https://custom.domain.com/', mail.html_part.body
        assert_not_contains 'href="https://example.com', mail.html_part.body
        assert_not_contains 'href="/', mail.html_part.body
        assert_contains @new_user_token, mail.html_part.body, "Could not find User's authentication token in the email: #{mail.html_part.body}"
        assert_not_contains @creator_token, mail.html_part.body, "Authentication token is included in the email, which is sent the new user - new user should not have access to creator's account!"
      end
    end

    should 'create_notify_of_wrong_phone_number_email' do
      @signup_creator.create_notify_of_wrong_phone_number_email!
      @user = FactoryGirl.create(:user)
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::WrongPhoneNumber, @user.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_equal [@user.email], mail.to
      assert_equal "#{@user.first_name}, we can't reach you!", mail.subject
      assert_contains 'We tried to send you a text message, but it looks like your mobile number isn’t valid.', mail.html_part.body
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end

    should 'create_create_user_via_bulk_uploader_email' do
      @signup_creator.create_create_user_via_bulk_uploader_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::CreatedViaBulkUploader, @user.id, 'cool_password')
      end
      mail = ActionMailer::Base.deliveries.last
      assert mail.html_part.body.include?(@user.first_name)
      assert_equal [@user.email], mail.to
      assert_equal "#{@user.first_name}, you were invited to #{@platform_context.decorate.name}!", mail.subject
      assert_contains "Hi #{@user.first_name}", mail.html_part.body
      assert_contains "We'd like to invite you to participate in our #{@platform_context.decorate.name} marketplace", mail.html_part.body
      assert_contains 'Password: cool_password', mail.html_part.body
      assert_contains 'href="https://custom.domain.com', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end

    should 'send email to approved user' do
      @signup_creator.create_approved_email!
      @user = FactoryGirl.create(:user)
      User.any_instance.stubs(:is_trusted?).returns(true)
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::Approved, @user.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_equal "#{@user.first_name}, you have been approved at #{@platform_context.decorate.name}!", mail.subject
      assert mail.html_part.body.include?(@user.first_name)
      assert_equal [@user.email], mail.to
      assert mail.html_part.body.include?('You have been approved')
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end
  end
end
