FactoryGirl.define do
  factory :blog_post do
    title { Faker::Lorem.words(4).join(' ').titleize }
    content { Faker::Lorem.paragraph }
    published_at { DateTime.now }
    blog_instance
    user
  end
end
