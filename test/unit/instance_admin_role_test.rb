require 'test_helper'

class InstanceAdminRoleTest < ActiveSupport::TestCase

  should have_many(:instance_admins)
  should belong_to(:instance)
  should validate_uniqueness_of(:name).scoped_to(:instance_id)
  should validate_presence_of(:name)


  should 'assign default role for instance admins whose role has been deleted' do
      @custom_role = FactoryGirl.create(:instance_admin_role)
      @instance_owner = FactoryGirl.create(:instance_admin, :instance_admin_role_id => @custom_role.id)
      @instance_admin = FactoryGirl.create(:instance_admin, :instance_admin_role_id => @custom_role.id)
      @instance_admin2 = FactoryGirl.create(:instance_admin, :instance_admin_role_id => @custom_role.id)
      @custom_role.destroy
      @instance_admin.reload
      @instance_admin2.reload
      assert_equal InstanceAdminRole.default_role, @instance_admin.instance_admin_role
      assert_equal InstanceAdminRole.default_role, @instance_admin2.instance_admin_role
  end

end
