# frozen_string_literal: true
FactoryGirl.define do
  factory :custom_image do
    association :custom_attribute
    association :uploader, factory: :user
    image { fixture_file_upload(Rails.root.join('test', 'assets', 'foobear.jpeg'), 'image/jpeg') }
  end
end
