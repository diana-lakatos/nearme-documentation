# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :instance_admin_role do

    sequence(:name) { |n| "InstanceAdminRole #{n}" }
    instance_id { (Instance.default_instance.presence || FactoryGirl.create(:instance)).id }
    permission_analytics true
    permission_settings false
    permission_theme false
    permission_transfers false
    permission_inventories false
    permission_partners false
    permission_users false

    factory :instance_admin_role_default do
      name 'Default'
      instance_id nil
      permission_analytics true
      permission_settings false
      permission_theme false
      permission_transfers false
      permission_inventories false
      permission_partners false
      permission_users false
    end

    factory :instance_admin_role_administrator do
      name 'Administrator'
      instance_id nil
      permission_settings true
      permission_theme true
      permission_transfers true
      permission_inventories true
      permission_partners true
      permission_users true
      permission_analytics true
    end
  end

end
