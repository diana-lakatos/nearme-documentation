# frozen_string_literal: true
FactoryGirl.define do
  factory :attachable_attachment, class: 'Attachable::Attachment' do
    attachable { FactoryGirl.create(:user_message, author: user) }
    file { fixture_file_upload(Rails.root.join('test', 'fixtures', 'avatar.jpg')) }
    association :user
  end
end
