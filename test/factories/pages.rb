FactoryGirl.define do

  factory :page do
    sequence(:path) { |n| "page-#{n}" }
    sequence(:slug) { |n| "page-#{n}" }
    content { Faker::Lorem.paragraph }
    theme_id { PlatformContext.current.instance.theme.id }
    redirect_url nil
  end

end
