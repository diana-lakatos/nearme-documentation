require 'test_helper'

class InstanceAdmin::AuthorizerTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @instance = FactoryGirl.create(:instance)
    @platform_context = PlatformContext.new
    @platform_context.stubs(:instance).returns(@instance)
    @authorizer = InstanceAdmin::Authorizer.new(@user, @platform_context)
    FactoryGirl.create(:instance_admin_role_default)
  end

  context 'instance_admin' do

    should 'know if user is not instance admin' do
      assert !@authorizer.instance_admin?
    end

    context 'is admin of at least one instance' do
      setup do
        @instance_admin = InstanceAdmin.create(:user_id => @user.id, :instance_id => @instance.id)
      end

      should 'know if user is instance admin' do
        assert @authorizer.instance_admin?
      end

      should 'not confuse instances' do
        @other_instance = FactoryGirl.create(:instance, :name => 'other_instance')
        @platform_context = PlatformContext.new
        @platform_context.stubs(:instance).returns(@other_instance)
        @authorizer = InstanceAdmin::Authorizer.new(@user, @platform_context)
        assert !@authorizer.instance_admin?
      end
    end

  end

  context 'authorized?' do

    setup do
      @role = FactoryGirl.create(:instance_admin_role)
      @instance_admin = FactoryGirl.create(:instance_admin, :user_id => @user.id, :instance_id => @instance.id)
      @instance_admin.update_attribute(:instance_owner, false)
      @instance_admin.update_attribute(:instance_admin_role_id, @role.id)
    end

    should 'know if user has permission to base controller' do
      assert @authorizer.authorized?(InstanceAdmin::BaseController)
    end

    should 'know if user has permission to analytics controller' do
      assert @authorizer.authorized?(InstanceAdmin::AnalyticsController)
    end

    should 'know if user has permission to settings controller' do
      @role.update_attribute(:permission_settings, true)
      assert @authorizer.authorized?(InstanceAdmin::SettingsController)
    end

    should 'know if user does not have permission to settings controller' do
      @role.update_attribute(:permission_settings, false)
      assert !@authorizer.authorized?(InstanceAdmin::SettingsController)
    end

    should 'know if user has permission to theme controller' do
      @role.update_attribute(:permission_theme, true)
      assert @authorizer.authorized?(InstanceAdmin::ThemeController)
    end

    should 'know if user does not have permission to theme controller' do
      @role.update_attribute(:permission_theme, false)
      assert !@authorizer.authorized?(InstanceAdmin::ThemeController)
    end

    should 'know if user has permission to pages controller' do
      @role.update_attribute(:permission_pages, true)
      assert @authorizer.authorized?(InstanceAdmin::PagesController)
    end

    should 'know if user does not have permission to pages controller' do
      @role.update_attribute(:permission_pages, false)
      assert !@authorizer.authorized?(InstanceAdmin::PagesController)
    end

    should 'know if user has permission to partners controller' do
      @role.update_attribute(:permission_partners, true)
      assert @authorizer.authorized?(InstanceAdmin::PartnersController)
    end

    should 'know if user does not have permission to partners controller' do
      @role.update_attribute(:permission_partners, false)
      assert !@authorizer.authorized?(InstanceAdmin::PartnersController)
    end

    should 'know if user has permission to inventories controller' do
      @role.update_attribute(:permission_inventories, true)
      assert @authorizer.authorized?(InstanceAdmin::InventoriesController)
    end

    should 'know if user does not have permission to inventories controller' do
      @role.update_attribute(:permission_inventories, false)
      assert !@authorizer.authorized?(InstanceAdmin::InventoriesController)
    end

    should 'know if user has permission to transfers controller' do
      @role.update_attribute(:permission_transfers, true)
      assert @authorizer.authorized?(InstanceAdmin::TransfersController)
    end

    should 'know if user does not have permission to transfers controller' do
      @role.update_attribute(:permission_transfers, false)
      assert !@authorizer.authorized?(InstanceAdmin::TransfersController)
    end

    should 'know if user has permission to users controller' do
      @role.update_attribute(:permission_users, true)
      assert @authorizer.authorized?(InstanceAdmin::UsersController)
    end

    should 'know if user does not have permission to users controller' do
      @role.update_attribute(:permission_users, false)
      assert !@authorizer.authorized?(InstanceAdmin::UsersController)
    end
  end

end
