require 'test_helper'

class BlogAdminAuthorizerTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @instance = FactoryGirl.create(:instance)
    @platform_context = PlatformContext.new
    @platform_context.stubs(:instance).returns(@instance)
    @authorizer = InstanceAdminAuthorizer.new(@user, @platform_context)
    FactoryGirl.create(:instance_admin_role_blog)
  end


end
