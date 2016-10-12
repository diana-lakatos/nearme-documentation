FactoryGirl.define do
  factory :user_blog_post do
    title { Faker::Lorem.words(4).join(' ').titleize }
    content { Faker::Lorem.paragraphs(3).join('<br/><br/>') }
    excerpt { Faker::Lorem.paragraph(2) }
    published_at_str { DateTime.now.strftime(I18n.t('datepicker.dformat')) }
    user
    author_name { Faker::Name.name }

    factory :highlighted_user_blog_post do
      highlighted true
    end

    factory :unpublished_user_blog_post do
      published_at { 1.week.from_now }
    end

    factory :published_user_blog_post do
      published_at { 1.week.ago }
    end
  end
end
