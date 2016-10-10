require 'test_helper'

class Utils::DefaultAlertsCreator::CollaboratorAlertTest < ActionDispatch::IntegrationTest
  setup do
    @creator = Utils::DefaultAlertsCreator::CollaboratorCreator.new

    @platform_context = PlatformContext.current
    @listing = FactoryGirl.create(:transactable)
    @collaborator = FactoryGirl.create(:transactable_collaborator, transactable: @listing)
    @user = @collaborator.user
  end

  should '#collaborator_approved' do
    @creator.create_collaborator_approved_email!

    assert_difference 'ActionMailer::Base.deliveries.size' do
      WorkflowStepJob.perform(WorkflowStep::CollaboratorWorkflow::CollaboratorApproved, @collaborator.id)
    end

    mail = ActionMailer::Base.deliveries.last

    [mail.html_part.body, mail.text_part.body.to_s].each do |body|
      assert_equal [@user.email], mail.to
      assert_equal "You've been approved as a collaborator on #{@listing.name}", mail.subject

      assert_contains "Hi, #{@user.first_name}", body

      assert_not_contains 'Liquid error:', body
      assert_not_contains 'translation missing:', body
    end

    assert_match /<a.*>#{@listing.administrator.name}<\/a> has approved you as a collaborator on/, mail.html_part.body.to_s
  end

  should '#collaborator_has_quit' do
    @creator.create_collaborator_has_quit_email!

    assert_difference 'ActionMailer::Base.deliveries.size' do
      WorkflowStepJob.perform(WorkflowStep::CollaboratorWorkflow::CollaboratorHasQuit, @listing, @user)
    end

    mail = ActionMailer::Base.deliveries.last

    [mail.html_part.body.to_s, mail.text_part.body.to_s].each do |body|
      assert_equal [@listing.administrator.email], mail.to
      assert_equal "#{@listing.administrator.first_name}, #{@user.first_name} decided to be no longer collaborator on #{@listing.name}", mail.subject

      assert_contains "Hi, #{@listing.administrator.first_name}", body
      assert_contains @user.first_name, body

      assert_not_contains 'Liquid error:', body
      assert_not_contains 'translation missing:', body
    end

    assert_match /<a .*>#{@user.first_name}<\/a>/, mail.html_part.body.to_s
  end
end
