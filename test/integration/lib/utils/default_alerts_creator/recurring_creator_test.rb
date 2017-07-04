require 'test_helper'

class Utils::DefaultAlertsCreator::RecurringCreatorTest < ActionDispatch::IntegrationTest
  setup do
    @recurring_creator = Utils::DefaultAlertsCreator::RecurringCreator.new
  end

  should 'create all' do
    @recurring_creator.expects(:create_share_email!).once
    @recurring_creator.expects(:create_request_photos_email!).once
    @recurring_creator.create_all!
  end

  context 'methods' do
    setup do
      @company = FactoryGirl.create(:company)
      @platform_context = PlatformContext.current
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, name: 'custom.domain.com'))
    end

    should 'create_share_email' do
      @reservation = FactoryGirl.create(:past_reservation)
      @listing = @reservation.transactable
      @user = @listing.administrator
      @recurring_creator.create_share_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RecurringWorkflow::Share, @listing.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_equal "Share your listing '#{@listing.name}' at #{@listing.location.street } and increase bookings!", mail.subject
      assert mail.html_part.body.include?(@user.first_name)
      assert_equal [@user.email], mail.to
      assert_contains "Share your listing on Facebook, Twitter, and LinkedIn, and start seeing #{@listing.transactable_type.translated_lessee(10)} book your Desk.", mail.html_part.body
      assert_not_contains 'translation missing:', mail.html_part.body
      assert mail.html_part.body.include?(@listing.name)
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end

    should 'create_request_photos_email' do
      @listing = FactoryGirl.create(:transactable)
      @user = @listing.administrator
      @recurring_creator.create_request_photos_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::RecurringWorkflow::RequestPhotos, @listing.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_equal 'Give the final touch to your listings with some photos!', mail.subject
      assert mail.html_part.body.include?(@user.first_name)
      assert_equal [@user.email], mail.to
      assert mail.html_part.body.include?('Listings with photos have 10x chances of getting booked.')
      assert mail.html_part.body.include?(@listing.name)
      assert_contains 'href="https://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end
  end
end
