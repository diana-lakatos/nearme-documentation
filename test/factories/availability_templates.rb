FactoryGirl.define do
  factory :availability_template do
    name "Working Week"
    description "Mon - Fri, 9:00 AM - 5:00 PM"

    after(:build) do |availability_template|
      (1..5).each do |i|
        availability_template.availability_rules << FactoryGirl.build(:availability_rule, :target => availability_template, day: i)
      end
    end
  end
end
