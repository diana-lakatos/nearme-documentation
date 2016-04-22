FactoryGirl.define do
  factory :availability_template do
    name "Working Week2"
    description "Mon - Fri, 9:00 AM - 5:00 PM"

    after(:build) do |availability_template|
      availability_template.availability_rules << FactoryGirl.build(:availability_rule, :target => availability_template, days: (0..5).to_a)
    end

    factory :availability_template_always_open do
      after(:build) do |availability_template|
        availability_template.availability_rules = []
        availability_template.availability_rules << FactoryGirl.build(:availability_rule, :always_open, :target => availability_template)
      end
    end

    factory :availability_template_every_other_day do
      after(:build) do |availability_template|
        availability_template.availability_rules = []
        availability_template.availability_rules << FactoryGirl.build(:availability_rule, :target => availability_template, day: [1,3,5])
      end
    end

  end


end
