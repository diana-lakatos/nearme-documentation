# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :instance_admin do

    after(:build) do
      FactoryGirl.create(:instance_admin_role_administrator) unless InstanceAdminRole.administrator_role
      FactoryGirl.create(:instance_admin_role_default) unless InstanceAdminRole.default_role
    end

    before(:create) do
      FactoryGirl.create(:instance_admin_role_administrator) unless InstanceAdminRole.administrator_role
      FactoryGirl.create(:instance_admin_role_default) unless InstanceAdminRole.default_role
    end

    instance_id { (Instance.default_instance.presence || FactoryGirl.create(:instance)).id }
    user

  end


end
