# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_template do
    html_body "html body"
    text_body "text body"
    path "weird/path"
    partial false
    theme { Instance.default_instance.theme }
  end
end
