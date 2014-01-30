# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :translation do
    locale 'en'
    key 'translation_key'
    value 'translation-value'
    instance_id { (Instance.default_instance.presence || FactoryGirl.create(:instance)).id }
  end
end
