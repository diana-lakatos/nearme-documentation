require 'test_helper'

class InstanceAdminTest < ActiveSupport::TestCase
  should belong_to(:instance)
  should belong_to(:user)
  should belong_to(:instance_admin_role)
  should validate_presence_of(:user_id)

  context 'default role' do
    should 'assign administrator and ownership to the first user and default to the rest' do
      @instance_owner = FactoryGirl.create(:instance_admin)
      @instance_admin = FactoryGirl.create(:instance_admin)
      assert_equal InstanceAdminRole.administrator_role, @instance_owner.instance_admin_role
      assert @instance_owner.instance_owner
      assert_equal InstanceAdminRole.default_role, @instance_admin.instance_admin_role
      assert !@instance_admin.instance_owner
    end
  end

  context 'transfer ownership' do
    should 'assign ownership to new user and revoke ownership from the previous user' do
      @instance_owner = FactoryGirl.create(:instance_admin)
      @instance_admin = FactoryGirl.create(:instance_admin)
      @instance_admin.mark_as_instance_owner
      assert !@instance_owner.reload.instance_owner
      assert @instance_admin.instance_owner
    end
  end

  context 'metadata' do
    context 'triggering' do
      should 'trigger populate instance admins metadata on user' do
        User.any_instance.expects(:populate_instance_admins_metadata!).once
        FactoryGirl.create(:instance_admin)
      end
    end
  end
end
