require 'test_helper'

class InstanceAdminRoleTest < ActiveSupport::TestCase

  should have_many(:instance_admins)
  should belong_to(:instance)
  should validate_presence_of(:name)


  should 'assign default role for instance admins whose role has been deleted' do
    @custom_role = FactoryGirl.create(:instance_admin_role)
    @instance_owner = FactoryGirl.create(:instance_admin).tap { |ia| ia.update_attribute(:instance_admin_role_id, @custom_role.id) }
    @instance_admin = FactoryGirl.create(:instance_admin).tap { |ia| ia.update_attribute(:instance_admin_role_id, @custom_role.id) }
    @instance_admin2 = FactoryGirl.create(:instance_admin).tap { |ia| ia.update_attribute(:instance_admin_role_id, @custom_role.id) }
    @custom_role.destroy
    assert_equal InstanceAdminRole.default_role, @instance_admin.reload.instance_admin_role
    assert_equal InstanceAdminRole.default_role, @instance_admin2.reload.instance_admin_role
  end

  context 'first_permission_have_access_to' do

    should 'return correct first permission have access to' do
      assert_equal "theme", FactoryGirl.create(:instance_admin_role, :permission_analytics => false, :permission_theme => true).first_permission_have_access_to
    end

    should 'return nil if all are false' do
      assert_nil FactoryGirl.create(:instance_admin_role, :permission_analytics => false).first_permission_have_access_to
    end
  end

  context 'metadata' do
    context 'triggering' do

      setup do
        @custom_role = FactoryGirl.create(:instance_admin_role)
      end

      should 'not trigger populate metadata if condition fails' do
        @custom_role.expects(:populate_instance_admins_metadata!).never
        @custom_role.expects(:should_populate_metadata?).returns(false)
        @custom_role.save!
      end

      should 'populate trigger populate metadata if condition succeeds' do
        @custom_role.expects(:populate_instance_admins_metadata!).once
        @custom_role.expects(:should_populate_metadata?).returns(true)
        @custom_role.save!
      end

    end

    context 'should_populate_metadata?' do

      setup do
        @instance_admin_role = FactoryGirl.create(:instance_admin_role)
      end

      should 'return false if instance_admin_role was destroyed' do
        instance_admin_role = FactoryGirl.create(:instance_admin_role)
        instance_admin_role.permission_analytics = true
        instance_admin_role.save

        instance_admin_role.destroy
        refute instance_admin_role.should_populate_metadata?
      end

      should 'return false if name was changed' do
        @instance_admin_role.update_attributes(:name => 'name was changed')
        refute @instance_admin_role.should_populate_metadata?
      end

      should 'return false if setting does not change first_permission' do
        @instance_admin_role.update_attribute(:permission_settings, true)
        refute @instance_admin_role.should_populate_metadata?
      end

      should 'return true if previous first_permission is being disabled' do
        @instance_admin_role.update_attribute(:permission_settings, true)
        @instance_admin_role.update_attribute(:permission_analytics, false)
        assert @instance_admin_role.should_populate_metadata?
      end

      should 'return true if setting that becomes first_permission is enabled' do
        @instance_admin_role.update_attributes(:permission_analytics => false)
        @instance_admin_role.update_attribute(:permission_settings, true)
        assert @instance_admin_role.should_populate_metadata?
      end

    end
  end

end
