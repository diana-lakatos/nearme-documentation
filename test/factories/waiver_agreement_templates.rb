FactoryGirl.define do
  factory :waiver_agreement_template do
    target { (Instance.first || FactoryGirl.create(:default_instance)) }
    content "# Markdown hello"
    sequence(:name) { |n| "Waiver Agreement Template #{n}" }
  end

end
