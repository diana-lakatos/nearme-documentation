FactoryGirl.define do

  factory :content_holder do
    sequence(:name) { |n| "page-#{n}" }
    content { Faker::Lorem.paragraph }
    theme_id { (Instance.first.theme || FactoryGirl.create(:instance).theme).id }
    instance_id { (Instance.first || FactoryGirl.create(:instance)).id }
    enabled true
  end

end
