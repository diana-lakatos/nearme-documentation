require 'test_helper'

class GroupMemberTest < ActiveSupport::TestCase

  test "#owner_cannot_leave_group raises an exepction when owner's membership is deleted" do
    assert_raises GroupMember::OwnerCannotLeaveGroup do
      membership = create(:group_member, email: 'email@gexample.com')
      membership.group.stubs(:creator_id).returns(membership.user_id)
      membership.destroy
    end
  end

  test '#owner_cannot_leave_group does not raise an exception when group is deleted' do
    assert_nothing_raised do
      membership = create(:group_member, email: 'email@gexample.com')
      membership.group.stubs(:creator_id).returns(membership.user_id)
      membership.destroyed_by_parent = true
      membership.destroy
    end
  end

  test '#owner_cannot_lose_moderate_rights raise an exception when owner has no moderator rights' do
    assert_raises GroupMember::OwnerCannotLoseModerateRights do
      membership = create(:group_member, moderator: true, email: 'email@gexample.com')
      membership.group.stubs(:creator_id).returns(membership.user_id)
      membership.moderator = false
      membership.save
    end
  end

end
