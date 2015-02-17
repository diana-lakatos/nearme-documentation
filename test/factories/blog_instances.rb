FactoryGirl.define do

  factory :blog_instance do
    sequence(:name) do |n|
      "Blog #{n}"
    end
    owner { Instance.first.presence || FactoryGirl.create(:instance) }
    enabled true
  end

end
