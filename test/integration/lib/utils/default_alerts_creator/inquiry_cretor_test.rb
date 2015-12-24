require 'test_helper'

class Utils::DefaultAlertsCreator::InquiryCreatorTest < ActionDispatch::IntegrationTest

  setup do
    @inquiry_creator = Utils::DefaultAlertsCreator::InquiryCreator.new
  end

  should 'create all' do
    @inquiry_creator.expects(:create_inquiry_created_host!).once
    @inquiry_creator.expects(:create_inquiry_created_guest!).once
    @inquiry_creator.create_all!
  end

  context 'methods' do
    setup do
      @inquiry = FactoryGirl.create(:inquiry)
    end

    should 'create_inquiry_created_host' do
      @inquiry_creator.create_inquiry_created_host!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::InquiryWorkflow::Created, @inquiry.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains "#{@inquiry.inquiring_user_name} has asked a question about #{@inquiry.listing.name} on #{PlatformContext.current.decorate.name}", mail.html_part.body
      assert_contains "#{@inquiry.message}", mail.html_part.body
      assert_equal [@inquiry.listing.creator.email], mail.to
      assert_equal "New enquiry from #{@inquiry.inquiring_user.name} about #{@inquiry.listing.name}", mail.subject
    end

    should 'create_inquiry_created_guest' do
      @inquiry_creator.create_inquiry_created_guest!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::InquiryWorkflow::Created, @inquiry.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains "Thanks for your inquiry about #{@inquiry.listing.name}. on #{PlatformContext.current.decorate.name}. A copy of your message is set out below.", mail.html_part.body
      assert_contains "#{@inquiry.message}", mail.html_part.body
      assert_equal [@inquiry.inquiring_user.email], mail.to
      assert_equal "We've passed on your inquiry about #{@inquiry.listing.name}", mail.subject
    end

  end

end

