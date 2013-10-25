FactoryGirl.define do

  factory :page do
    sequence(:path) { |n| "page-#{n}" }
    content { Faker::Lorem.paragraph }
    theme_id { (Instance.default_instance.theme || FactoryGirl.create(:instance).theme).id }
  end

end
