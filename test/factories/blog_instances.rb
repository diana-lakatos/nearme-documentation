FactoryGirl.define do

  factory :blog_instance do
    sequence(:name) do |n|
      "Blog #{n}"
    end
    owner { Instance.default_instance.presence || FactoryGirl.create(:instance) }
  end

end
