require 'test_helper'

class SavedSearchesAlertsJobTest < ActiveSupport::TestCase

  setup do
    stub_request(:get, "http://maps.googleapis.com/maps/api/geocode/json?address=Auckland&language=en&sensor=false").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: "", headers: {})
    @user = FactoryGirl.create(:user)
    @saved_search = FactoryGirl.create(:saved_search,
      user: @user,
      query: '?loc=Auckland&query=&transactable_type_id=1&buyable=false'
    )
  end

  should 'send notification if there are new search results' do
    FactoryGirl.create('listing_in_auckland')
    WorkflowStepJob.expects(:perform).with(WorkflowStep::SavedSearchWorkflow::Daily, {@saved_search.id => 1}).once
    SavedSearchesAlertsJob.perform(:daily)
  end

  should 'send notification if there are new search results if notification was not sent during the period' do
    FactoryGirl.create('listing_in_auckland')
    @user.update_column :saved_searches_alert_sent_at, 36.hours.ago
    WorkflowStepJob.expects(:perform).with(WorkflowStep::SavedSearchWorkflow::Daily, {@saved_search.id => 1}).once
    SavedSearchesAlertsJob.perform(:daily)
  end

  should 'update users saved_searches_alert_sent_at' do
    last_saved_searches_alert_sent_at = @user.saved_searches_alert_sent_at
    SavedSearchesAlertsJob.perform(:daily)
    assert_not_equal last_saved_searches_alert_sent_at, @user.reload.saved_searches_alert_sent_at
  end

  should 'not send notification if there are no search results' do
    WorkflowStepJob.expects(:perform).never
    SavedSearchesAlertsJob.perform(:daily)
  end

  should 'not send notification if there are no search results if it was sent during the period' do
    FactoryGirl.create('listing_in_auckland')
    @user.update_column :saved_searches_alert_sent_at, 12.hours.ago
    WorkflowStepJob.expects(:perform).with(WorkflowStep::SavedSearchWorkflow::Daily, {@saved_search.id => 1}).never
    SavedSearchesAlertsJob.perform(:daily)
  end

end
