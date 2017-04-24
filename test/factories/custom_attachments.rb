# frozen_string_literal: true
FactoryGirl.define do
  factory :custom_attachment do
    association :custom_attribute
    association :uploader, factory: :user
    file { fixture_file_upload(Rails.root.join('test', 'assets', 'foobear.jpeg'), 'image/jpeg') }
  end
end
