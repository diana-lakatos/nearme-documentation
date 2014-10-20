require 'test_helper'

class Utils::DefaultAlertsCreator::ListingCreatorTest < ActionDispatch::IntegrationTest

  setup do
    @listing_creator = Utils::DefaultAlertsCreator::ListingCreator.new
  end

  should 'create all' do
    @listing_creator.expects(:create_listing_created_email!).once
    @listing_creator.expects(:create_draft_listing_created_email!).once
    @listing_creator.expects(:share_with_user_email!).once
    @listing_creator.create_all!
  end

  context 'methods' do
    setup do
      stub_mixpanel
      @platform_context = PlatformContext.current
      @instance = @platform_context.instance
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, :name => 'custom.domain.com'))
    end

    context 'draft listing' do

      setup do
        @listing_creator.create_draft_listing_created_email!
      end

      should 'created draft listing when draft' do
        @transactable = FactoryGirl.create(:transactable, draft: Time.zone.now)
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::DraftCreated, @transactable.id)
        end
        mail = ActionMailer::Base.deliveries.last
        assert_equal "[#{@platform_context.decorate.name}] #{@transactable.creator.first_name}, you're almost ready for your first guests!", mail.subject
        assert mail.html_part.body.include?(@transactable.creator.first_name)
        assert_equal [@transactable.creator.email], mail.to
        assert mail.html_part.body.include?("There are people looking for Desks in your area")
        assert_contains 'href="http://custom.domain.com/', mail.html_part.body
        assert_not_contains 'href="http://example.com', mail.html_part.body
        assert_not_contains 'href="/', mail.html_part.body
      end

      should 'not send draft listing is it is not draft anymore' do
        @transactable = FactoryGirl.create(:transactable)
        assert_no_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::DraftCreated, @transactable.id)
        end
      end
    end

    should 'created listing' do
      @listing_creator.create_listing_created_email!
      @listing = FactoryGirl.create(:transactable)
      @user = @listing.creator
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::Created, @listing.id)
      end
      mail = ActionMailer::Base.deliveries.last
      subject = "[#{@platform_context.decorate.name}] #{@user.first_name}, your new listing looks amazing!"

      assert_equal subject, mail.subject
      assert mail.html_part.body.include?(@user.first_name)
      assert_equal [@user.email], mail.to
      assert mail.html_part.body.include?("Your new listing rocks!")
      assert_contains 'href="http://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="http://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end

    should 'share with user' do
      @listing_creator.share_with_user_email!
      @listing = FactoryGirl.create(:transactable)
      @sharer = FactoryGirl.create(:user, name: 'Sharer Name')
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::Shared, @listing.id, 'friend@example.com', 'John Doe', @sharer.id, 'Check it out')
      end
      mail = ActionMailer::Base.deliveries.last
      assert_equal "#{@sharer.name} has shared a #{PlatformContext.current.decorate.bookable_noun} with you on #{PlatformContext.current.decorate.name}", mail.subject
      assert_contains "#{@sharer.name} has shared a #{PlatformContext.current.decorate.bookable_noun} with you!", mail.html_part.body
      assert_contains "View #{@listing.name} on #{PlatformContext.current.decorate.name}", mail.html_part.body
      assert_equal ['friend@example.com'], mail.to
      assert_contains 'href="http://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="http://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_contains 'Check it out', mail.html_part.body
    end

  end

end

