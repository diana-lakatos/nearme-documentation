# frozen_string_literal: true
FactoryGirl.define do
  factory :instance_view do
    body "%h1\n\tHello"
    path 'public/index'
    format 'html'
    handler 'haml'
    partial false
    instance { PlatformContext.current.instance }
    locale_ids { Locale.pluck(:id) }
    transactable_type_ids { TransactableType.pluck(:id) }

    factory :instance_view_sms do
      body 'Hello {{user.name}}'
      path 'custom_sms_templates/custom_template'
      format 'text'
      handler 'liquid'
    end

    factory :instance_view_email_html do
      body 'Hello {{dummy_arg.name}}'
      format 'html'
      handler 'liquid'
      path 'custom_email_templates/custom_template'
    end

    factory :instance_view_email_html_blank do
      body 'Hello'
      format 'html'
      handler 'liquid'
      path 'custom_email_templates/custom_template'
    end

    factory :instance_view_email_text do
      body 'Hello {{dummy_arg.name}}'
      format 'text'
      handler 'liquid'
      path 'custom_email_templates/custom_template'
    end

    factory :instance_view_layout do
      body 'This is header {{ content_for_layout }} This is footer'
      path 'layouts/custom_layout'
      format 'html'
      handler 'liquid'
    end

    factory :instance_view_footer do
      body 'This is footer'
      path 'layouts/theme_footer'
      format 'html'
      handler 'liquid'
      partial true
    end
  end
end
