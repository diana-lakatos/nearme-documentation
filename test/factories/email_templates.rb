# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_template do
    html_body "html body"
    text_body "text body"
    path "weird/path"
    partial false
    instance { Instance.default_instance || FactoryGirl.create(:instance) }
  end
end
