FactoryGirl.define do
  factory :waiver_agreement_template do
    target { PlatformContext.current.instance }
    content '# Markdown hello'
    sequence(:name) { |n| "Waiver Agreement Template #{n}" }
  end
end
