FactoryGirl.define do

  factory :page do
    sequence(:path) { |n| "page-#{n}" }
    content { Faker::Lorem.paragraph }
    theme_id { (Instance.first.theme || FactoryGirl.create(:instance).theme).id }
    redirect_url nil
  end

end
