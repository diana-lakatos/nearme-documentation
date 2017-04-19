# frozen_string_literal: true
FactoryGirl.define do
  factory :page do
    sequence(:path) { |n| "page-#{n}" }
    sequence(:slug) { |n| "page-#{n}" }
    content { Faker::Lorem.paragraph }
    theme_id { PlatformContext.current.instance.theme.id }
    redirect_url nil

    factory :page_contact_form do
      path 'refer-contact'
      slug 'refer-contact'
      content do
        %(
          <div>
            {% render_form instance_customization, object_class: 'Customization', parent_object_class: 'CustomModelType', parent_object_id: 'refer_contact', object_id: 'new' %}
          </div>
        )
      end
    end
  end
end
