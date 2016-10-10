FactoryGirl.define do
  factory :custom_theme do
    sequence(:name) { |n| "Custom Theme #{n}" }
    in_use true
    themeable { PlatformContext.current.instance }
  end
end
