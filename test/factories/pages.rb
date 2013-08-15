FactoryGirl.define do

  factory :page do
    sequence(:path) { |n| "page-#{n}" }
    content { Faker::Lorem.paragraph }
    instance_id { (Instance.default_instance || FactoryGirl.create(:instance)).id }
  end

end
