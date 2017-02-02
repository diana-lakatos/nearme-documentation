require 'test_helper'

class Dashboard::ProjectsControllerTest < ActionController::TestCase
  context 'project activity feed events' do
    setup do
      @transactable = FactoryGirl.create(:project)
      @collaborator_user = FactoryGirl.create(:user)

      @transactable_collaborator = TransactableCollaborator.create(user: @collaborator_user, transactable: @transactable, approved_by_user_at: Time.now, approved_by_owner_at: Time.now)
    end

    should 'should create new link event when transactable creator adds link' do
      sign_in @transactable.creator

      check_activity_feed_event_created_on_new_link_added
    end

    should 'should create new link event when collaborator adds link' do
      sign_in @collaborator_user

      check_activity_feed_event_created_on_new_link_added
    end
  end

  protected

  def check_activity_feed_event_created_on_new_link_added
    Transactable.any_instance.stubs(:photo_not_required).returns(true)
    assert_difference 'ActivityFeedEvent.count' do
      put :update, transactable: { "description"=>"test", "topic_ids"=>["", @transactable.topics.first.id], "links_attributes"=>{"1485873078028"=>{"_destroy"=>"false", "url"=>"http://linkto.com/", "text"=>"LinkText"}} }, project_type_id: @transactable.transactable_type_id, id: @transactable.id
    end
    Transactable.any_instance.unstub(:photo_not_required)

    last_afe = ActivityFeedEvent.last
    assert_equal 'user_added_links_to_transactable', last_afe.event
  end

end

