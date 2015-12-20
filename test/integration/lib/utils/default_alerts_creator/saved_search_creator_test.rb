require 'test_helper'

class Utils::DefaultAlertsCreator::SavedSearchCreatorTest < ActionDispatch::IntegrationTest

  setup do
    @saved_search_creator = Utils::DefaultAlertsCreator::SavedSearchCreator.new
  end

  should 'create all' do
    @saved_search_creator.expects(:notify_user_of_daily_results!).once
    @saved_search_creator.expects(:notify_user_of_weekly_results!).once
    @saved_search_creator.create_all!
  end

  context 'methods' do

    setup do
      @user = FactoryGirl.create(:user)
      @saved_search = FactoryGirl.create(:saved_search,
        user: @user,
        query: '?loc=Auckland&query=&transactable_type_id=1&buyable=false'
      )
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, name: 'custom.domain.com'))
      SavedSearch.any_instance.stubs(:new_results).returns(31337)
      FactoryGirl.create('listing_in_auckland')
    end

    should 'create_instance_created_email' do
      @saved_search_creator.notify_user_of_daily_results!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::SavedSearchWorkflow::Daily, [@saved_search.id])
      end

      mail = ActionMailer::Base.deliveries.last
      assert_equal [@user.email], mail.to
      assert_contains 'search results for', mail.subject

      %w(html text).each do |format|
        assert_contains '31337', mail.send("#{format}_part").body
        assert_contains 'new search results for', mail.send("#{format}_part").body
        assert_contains 'http://custom.domain.com/', mail.send("#{format}_part").body
        assert_not_contains 'http://example.com/', mail.send("#{format}_part").body
        assert_not_contains 'http://localhost:3000', mail.send("#{format}_part").body
      end
    end
  end

end
