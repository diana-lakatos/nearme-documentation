require 'test_helper'

class InstanceAdminAuthorizerTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @authorizer = InstanceAdminAuthorizer.new(@user)
    FactoryGirl.create(:instance_admin_role_default)
  end

  context 'instance_admin' do

    should 'know that user is not instance admin' do
      assert !@authorizer.instance_admin?
    end

    context 'is admin of at least one instance' do
      setup do
        @instance_admin = InstanceAdmin.create(:user_id => @user.id)
      end

      should 'know that user is instance admin' do
        assert @authorizer.instance_admin?
      end

      should 'not confuse instances' do
        @instance_admin.update_attribute(:instance_id, FactoryGirl.create(:instance).id)
        refute @authorizer.instance_admin?
      end
    end

  end

  context 'authorized?' do

    setup do
      @role = FactoryGirl.create(:instance_admin_role)
      @instance_admin = FactoryGirl.create(:instance_admin, :user_id => @user.id)
      @instance_admin.update_attribute(:instance_owner, false)
      @instance_admin.update_attribute(:instance_admin_role_id, @role.id)
    end

    should 'know if user has permission to base controller' do
      assert @authorizer.authorized?('InstanceAdmin')
    end

    should 'know if user has permission to analytics controller' do
      @role.update_attribute(:permission_analytics, true)
      assert @authorizer.authorized?('Analytics')
    end

    should 'know if user does not has permission to analytics controller' do
      @role.update_attribute(:permission_analytics, false)
      assert !@authorizer.authorized?('Analytics')
    end

    should 'know if user has permission to settings controller' do
      @role.update_attribute(:permission_settings, true)
      assert @authorizer.authorized?('Settings')
    end

    should 'know if user does not have permission to settings controller' do
      @role.update_attribute(:permission_settings, false)
      assert !@authorizer.authorized?('Settings')
    end

    should 'know if user has permission to theme controller' do
      @role.update_attribute(:permission_theme, true)
      assert @authorizer.authorized?('Theme')
    end

    should 'know if user does not have permission to theme controller' do
      @role.update_attribute(:permission_theme, false)
      assert !@authorizer.authorized?('Theme')
    end

    should 'know if user has permission to manage controller' do
      @role.update_attribute(:permission_manage, true)
      assert @authorizer.authorized?('Manage')
    end

    should 'know if user does not have permission to manage controller' do
      @role.update_attribute(:permission_manage, false)
      assert !@authorizer.authorized?('Manage')
    end

    should 'know if user has permission to buy sell controller' do
      @role.update_attribute(:permission_buysell, true)
      assert @authorizer.authorized?('BuySell')
    end

    should 'know if user does not have permission to buy sell controller' do
      @role.update_attribute(:permission_buysell, false)
      assert !@authorizer.authorized?('BuySell')
    end

    should 'know if user has permission to support controller' do
      @role.update_attribute(:permission_support, true)
      assert @authorizer.authorized?('Support')
    end

    should 'know if user does not have permission to support controller' do
      @role.update_attribute(:permission_support, false)
      assert !@authorizer.authorized?('Support')
    end

    should 'raise InstanceAdminAuthorizer::UnassignedInstanceAdminRoleError if instance_admin has no role' do
      @instance_admin.update_column(:instance_admin_role_id, nil)
      assert_raise InstanceAdminAuthorizer::UnassignedInstanceAdminRoleError do
        assert !@authorizer.authorized?('Analytics')
      end
    end
  end

  context 'first_permission_have_access_to' do
    setup do
      @role = FactoryGirl.create(:instance_admin_role)
      @role.update_attribute(:permission_analytics, false)
      @role.update_attribute(:permission_settings, true)
      @role.update_attribute(:permission_theme, true)
      @instance_admin = FactoryGirl.create(:instance_admin, :user_id => @user.id)
      @instance_admin.update_attribute(:instance_owner, false)
      @instance_admin.update_attribute(:instance_admin_role_id, @role.id)
    end

    should 'return first permission/page user has access to' do
      assert_equal @authorizer.first_permission_have_access_to, 'settings'
    end
  end

end
