require 'test_helper'

class BlogAdminAuthorizerTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @instance = FactoryGirl.create(:instance)
    @platform_context = PlatformContext.new
    @platform_context.stubs(:instance).returns(@instance)
    @authorizer = BlogAdminAuthorizer.new(@user, @platform_context)
    @default_role = FactoryGirl.create(:instance_admin_role_default)
    @instance_admin = FactoryGirl.create(:instance_admin, user_id: @user.id,
                                                          instance_id: @instance.id,
                                                          instance_admin_role_id: @default_role.id)
    @instance_admin.update_attribute(:instance_owner, false)
  end

  context 'authorized?' do

    should 'not authorize if user isnt instance_owner nor has blog permission' do
      refute @authorizer.authorized?
    end

    should 'authorize if user is instance owner' do
      @instance_admin.update_attribute(:instance_owner, true)

      assert @authorizer.authorized?
    end

    should 'authorize if user has blog permission' do
      @blog_role = FactoryGirl.create(:instance_admin_role_blog)
      @instance_admin.update_attribute(:instance_admin_role_id, @blog_role.id)

      assert @authorizer.authorized?
    end
  end

end
