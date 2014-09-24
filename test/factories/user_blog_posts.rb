FactoryGirl.define do

  factory :user_blog_post do
    title { Faker::Lorem.words(4).join(' ').titleize }
    content { Faker::Lorem.paragraphs(3).join('<br/><br/>') }
    excerpt { Faker::Lorem.paragraph(2) }
    published_at { DateTime.now }
    user
  end

end
