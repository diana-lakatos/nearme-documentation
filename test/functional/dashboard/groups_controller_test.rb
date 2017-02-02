require 'test_helper'

class Dashboard::GroupsControllerTest < ActionController::TestCase
  context 'group' do
    setup do
      @group = FactoryGirl.create(:group)
      @collaborator_user = FactoryGirl.create(:user)
      GroupMember.create!(user: @group.creator, group: @group, moderator: true, approved_by_owner_at: Time.now, approved_by_user_at: Time.now)
      GroupMember.create!(user: @collaborator_user, group: @group, moderator: true, approved_by_owner_at: Time.now, approved_by_user_at: Time.now)
    end

    should 'should create new link event when creator adds link' do
      sign_in @group.creator

      check_activity_feed_event_created_on_new_link_added
    end

    should 'should create new link event when collaborator adds link' do
      sign_in @collaborator_user

      check_activity_feed_event_created_on_new_link_added
    end
  end

  protected

  def check_activity_feed_event_created_on_new_link_added
    assert_difference 'ActivityFeedEvent.count' do
      put :update, group: {"name"=>"Test", "links_attributes"=>{"1485874485257"=>{"url"=>"http://newlinky.com", "text"=>"NewLinky", "_destroy"=>"false"}}, "cover_photo_attributes"=>{"id"=>@group.cover_photo.id, "photo_role"=>"cover"}}, id: @group.id
    end

    last_afe = ActivityFeedEvent.last
    assert_equal 'user_added_links_to_group', last_afe.event
  end

end
