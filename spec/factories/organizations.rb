FactoryGirl.define do
  factory :organization do
    sequence(:name) { |n| name { "Organization #{n}" } }
    factory :organization_with_logo do
      logo { File.open(File.join(Rails.root, 'spec', 'assets', 'foobear.jpeg')) }
    end
  end
end
