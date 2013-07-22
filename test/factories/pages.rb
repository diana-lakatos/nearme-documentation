FactoryGirl.define do

  factory :page do
    sequence(:path) { |n| "page-#{n}" }
    instance { Instance.default_instance || FactoryGirl.create(:instance) }
  end

end
