require 'test_helper'

class InstanceAdminTest < ActiveSupport::TestCase

  should belong_to(:instance)
  should belong_to(:user)
  should belong_to(:instance_admin_role)
  should validate_uniqueness_of(:user_id).scoped_to(:instance_id)
  should validate_presence_of(:user_id)
  should validate_presence_of(:instance_id)

  context 'default role' do

    should 'assign administrator to the first user and default to the rest' do
      @instance_owner = FactoryGirl.create(:instance_admin)
      @instance_admin = FactoryGirl.create(:instance_admin)
      assert_equal InstanceAdminRole.administrator_role, @instance_owner.instance_admin_role
      assert @instance_owner.instance_owner
      assert_equal InstanceAdminRole.default_role, @instance_admin.instance_admin_role
      assert !@instance_admin.instance_owner
    end

  end

  context 'metadata' do

    context 'triggering' do

      should 'not trigger populate metadata on listing if condition fails' do
        User.any_instance.expects(:populate_instance_admins_metadata!).once
        FactoryGirl.create(:instance_admin)
      end

    end
  end

end
