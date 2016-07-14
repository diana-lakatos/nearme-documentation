require 'test_helper'

class GroupDecoratorTest < Draper::TestCase

  test '#is_owner?' do
    @user = create(:user)
    @group = create(:group, creator: @user)
    @group_decorator = GroupDecorator.new(@group)

    assert @group_decorator.is_owner?(@user)
  end

  test '#is_moderator?' do
    @user = create(:user)
    @group = create(:group)
    @membership = create(:group_member, user: @user, group: @group, moderator: true)
    @group_decorator = GroupDecorator.new(@group)

    assert @group_decorator.is_moderator?(@user)
  end

  test '#role_of_user returns "owner" for owner' do
    @user = create(:user)
    @group = create(:group, creator: @user)
    @group_decorator = GroupDecorator.new(@group)

    assert_equal :owner, @group_decorator.role_of_user(@user)
  end

  test '#role_of_user returns "moderator" for moderator' do
    @user = create(:user)
    @group = create(:group)
    @membership = create(:group_member, user: @user, group: @group, moderator: true)
    @group_decorator = GroupDecorator.new(@group)

    assert_equal :moderator, @group_decorator.role_of_user(@user)
  end

  test '#role_of_user returns "member" for member' do
    @user = create(:user)
    @group = create(:group)
    @membership = create(:group_member, user: @user, group: @group, moderator: false)
    @group_decorator = GroupDecorator.new(@group)

    assert_equal :member, @group_decorator.role_of_user(@user)
  end

end
