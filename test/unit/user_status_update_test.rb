require 'test_helper'

class UserStatusUpdateTest < ActiveSupport::TestCase

  context "included modules" do
    %w(
      PlatformContext::DefaultScoper
      PlatformContext::ForeignKeysAssigner
    ).each do |_module|
      should "include #{_module}" do
        assert ActivityFeedEvent.included_modules.map(&:to_s).include?(_module)
      end
    end
  end

  context "associations" do
    should belong_to(:user)
    should have_and_belong_to_many(:topics)
  end

  context "callbacks" do
    should "#create_activity_feed_event after_commit on: :create" do
      assert_difference "ActivityFeedEvent.count" do
        create(:user_status_update)
      end

      assert_equal :user_updated_user_status, ActivityFeedEvent.last.event.to_sym
    end
  end

  test '#user_status_for_group_updated?' do
    @group = create(:group)
    @status = build(:user_status_update, updateable: @group)

    assert @status.send(:user_status_for_group_updated?)
  end

  test 'update status for group when user is a member' do
    @user = create(:user)
    @group = create(:group)
    @status = build(:user_status_update, updateable: @group, user: @user)
    @user.stubs(:is_member_of?).with(@group).returns(true)

    @status.valid?

    assert_not @status.errors.include?(:membership)
  end

  test 'do not update status for group when user is not a member' do
    @user = create(:user)
    @group = create(:group)
    @status = build(:user_status_update, updateable: @group, user: @user)
    @user.stubs(:is_member_of?).with(@group).returns(false)

    @status.valid?

    assert @status.errors.include?(:membership)
  end
end
