FactoryGirl.define do
  factory :content_holder do
    sequence(:name) { |n| "page-#{n}" }
    content { Faker::Lorem.paragraph }
    theme_id { (PlatformContext.current.theme || FactoryGirl.create(:instance).theme).id }
    instance_id { (PlatformContext.current.instance || FactoryGirl.create(:instance)).id }
    enabled true
  end
end
