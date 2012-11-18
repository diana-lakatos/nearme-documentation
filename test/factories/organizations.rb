FactoryGirl.define do
  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }

    factory :aarp do
      name 'AARP'
    end

    factory :darpa do
      name 'DARPA'
    end

    factory :nra do
      name 'NRA'
    end
    factory :organization_with_logo do
      logo { File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')) }
    end
  end
end
