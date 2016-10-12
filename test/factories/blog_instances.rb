FactoryGirl.define do
  factory :blog_instance do
    sequence(:name) do |n|
      "Blog #{n}"
    end
    owner { PlatformContext.current.instance }
    enabled true
  end
end
