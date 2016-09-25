require 'test_helper'

class Utils::DefaultAlertsCreator::OfferCreatorTest < ActionDispatch::IntegrationTest

  setup do
    @creator = Utils::DefaultAlertsCreator::OfferCreator.new
  end

  should 'create all' do
    @creator.create_all!
  end

  context 'methods' do
    setup do
      @offer = FactoryGirl.create :reservation
      @enquirer = @offer.owner
      @platform_context = PlatformContext.current
    end
    should 'create_inquiry_created_guest' do
      @creator.notify_host_offer_confirmed_email!

      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::OfferWorkflow::ManuallyConfirmed, @offer.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains "Thanks for confirming #{@enquirer.first_name}'s booking for", mail.html_part.body
      assert_equal "[#{@platform_context.decorate.name}] Thanks for confirming!", mail.subject
    end
  end
end
