# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :footer_template do
    body "body"
    path "weird/path"
    partial false
    theme { Instance.default_instance.theme }
  end
end
