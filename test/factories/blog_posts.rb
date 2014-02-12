FactoryGirl.define do

  factory :blog_post do
    title { Faker::Lorem.words(4).join(" ").titleize }
    content { Faker::Lorem.paragraph }
    blog_instance
    user
  end

end
